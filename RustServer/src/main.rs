pub mod action_handlers;
pub mod actions;
pub mod client;
pub mod error;
pub mod game_mode;
pub mod lobby;
pub mod lua_parser;
pub mod lua_ser;

use crate::action_handlers::{
    action_game_info, action_play_hand, action_ready_blind, action_unready_blind,
    create_lobby_action, join_lobby_action, leave_lobby_action, lobby_info_action,
    start_game_action, stop_game_action, username_action,
};
use crate::actions::ActionClientToServer;
use crate::client::Client;
use crate::lobby::Lobby;
use crate::lua_parser::action_from_string;
use dashmap::DashMap;
use game_mode::{initialize_gamemodes, GAME_MODES};
use std::env;
use std::error::Error;
use std::sync::Arc;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::TcpListener;
use tokio::sync::Mutex;
use tracing::*;
use uuid::Uuid;

pub const VERSION: &str = env!("CARGO_PKG_VERSION");

pub fn print_client_ids(clients: &DashMap<Uuid, Client>) {
    let client_ids = clients.iter().map(|pair| *pair.key()).collect::<Vec<_>>();
    info!(?client_ids);
}

pub async fn server() -> Result<(), Box<dyn Error>> {
    let addr = env::args()
        .nth(1)
        .unwrap_or_else(|| "0.0.0.0:8080".to_string());

    let listener = TcpListener::bind(&addr).await?;
    info!("Listening on: {}", addr);

    let clients: Arc<DashMap<Uuid, Client>> = Arc::new(DashMap::new());
    let lobbies: Arc<DashMap<String, Lobby>> = Arc::new(DashMap::new());

    loop {
        let (socket, client_addr) = listener.accept().await?;
        let buf_reader = Arc::new(Mutex::new(BufReader::new(socket)));

        let clients_ref = Arc::clone(&clients);
        let lobbies_ref = Arc::clone(&lobbies);
        info!(?client_addr, "Accepted connection");

        let client_id = Uuid::new_v4();
        let client = Client::new(client_id, client_addr, Arc::clone(&buf_reader));
        clients_ref.insert(client_id, client);

        print_client_ids(&clients_ref);

        tokio::spawn(async move {
            let mut buf: Vec<u8> = vec![0; 1024];

            loop {
                buf.clear();

                let result = buf_reader
                    .lock()
                    .await
                    .read_until(b'\n', &mut buf)
                    .await
                    .expect("Could not read from socket");

                if result == 0 {
                    clients_ref.remove(&client_id);

                    print_client_ids(&clients_ref);

                    info!(?client_addr, "Connection closed");
                    return;
                }

                let msg = String::from_utf8_lossy(&buf);
                let action = action_from_string(&msg);

                if let Err(error) = action {
                    error!("Could not parse action {}: {}", msg, error);
                    continue;
                }

                use ActionClientToServer::*;
                match action.unwrap() {
                    Username { username } => {
                        username_action(Arc::clone(&clients_ref), &client_id, username)
                    }
                    CreateLobby { game_mode } => create_lobby_action(
                        Arc::clone(&clients_ref),
                        Arc::clone(&lobbies_ref),
                        &client_id,
                        game_mode,
                    ),
                    JoinLobby { code } => {
                        join_lobby_action(Arc::clone(&lobbies_ref), &client_id, code.as_str())
                    }
                    LeaveLobby => leave_lobby_action(Arc::clone(&lobbies_ref), &client_id),
                    LobbyInfo => {
                        lobby_info_action(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                        )
                        .await
                    }
                    StopGame => {
                        stop_game_action(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                        )
                        .await
                    }
                    StartGame => {
                        start_game_action(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                        )
                        .await
                    }
                    ReadyBlind => {
                        action_ready_blind(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                        )
                        .await
                    }
                    UnreadyBlind => action_unready_blind(Arc::clone(&clients_ref), &client_id),
                    PlayHand { score, hands_left } => {
                        action_play_hand(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                            score,
                            hands_left,
                        )
                        .await
                    }
                    GameInfo => {
                        action_game_info(
                            Arc::clone(&lobbies_ref),
                            Arc::clone(&clients_ref),
                            &client_id,
                        )
                        .await
                    }
                    PlayerInfo => {}
                    EnemyInfo => {}
                    FailRound => todo!(),
                    SetAnte { ante } => todo!(),
                    Version { version } => todo!(),
                }
            }
        });
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    tracing_subscriber::fmt::init();

    GAME_MODES.get_or_init(initialize_gamemodes).await;
    server().await
}
