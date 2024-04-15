pub mod actions;
pub mod client;
pub mod error;
pub mod lobby;
pub mod lua_parser;
pub mod lua_ser;

use crate::actions::ActionClientToServer;
use crate::client::Client;
use crate::lobby::{GameMode, Lobby};
use crate::lua_parser::action_from_string;
use dashmap::DashMap;
use std::env;
use std::error::Error;
use std::sync::Arc;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::net::TcpListener;
use tracing::*;
use tracing_subscriber;
use uuid::Uuid;

pub fn print_client_ids(clients: &DashMap<Uuid, Client>) {
    let client_ids = clients
        .iter()
        .map(|pair| pair.key().clone())
        .collect::<Vec<_>>();
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
        let clients_ref = clients.clone();
        let lobbies_ref = lobbies.clone();

        let (socket, client_addr) = listener.accept().await?;
        info!(?client_addr, "Accepted connection");

        let client_id = Uuid::new_v4();
        let client = Client::new(client_id, client_addr);
        clients_ref.insert(client_id, client);

        print_client_ids(&clients_ref);

        tokio::spawn(async move {
            let mut buf: Vec<u8> = vec![0; 1024];
            let mut br = BufReader::new(socket);

            loop {
                buf.clear();

                let result = br
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

                if action.is_err() {
                    error!("Could not parse action {}", msg);
                    continue;
                }

                use ActionClientToServer::*;
                match action.unwrap() {
                    Username { username } => {
                        let mut client = clients_ref.get_mut(&client_id).unwrap();
                        client.username = username;
                    }
                    CreateLobby { game_mode } => {
                        let game_mode: GameMode = game_mode.try_into().unwrap_or_default();
                        let lobby = Lobby::new(Some(client_id)).with_gamemode(game_mode);
                        lobbies_ref.insert(lobby.code.clone(), lobby);
                    }
                    JoinLobby { code } => todo!(),
                    LeaveLobby => todo!(),
                    LobbyInfo => todo!(),
                    StopGame => todo!(),
                    StartGame => todo!(),
                    ReadyBlind => todo!(),
                    UnreadyBlind => todo!(),
                    PlayHand { score, hands_left } => todo!(),
                    GameInfo => todo!(),
                    PlayerInfo => todo!(),
                    EnemyInfo => todo!(),
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

    server().await
}
