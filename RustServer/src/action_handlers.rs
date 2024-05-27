use crate::{
    actions::ActionServerToClient,
    client::Client,
    game_mode::GAME_MODES,
    lobby::{GameMode, Lobby},
    VERSION,
};
use dashmap::DashMap;
use rand::Rng;
use std::{iter, sync::Arc};
use uuid::Uuid;

pub async fn broadcast_action(
    clients: Arc<DashMap<Uuid, Client>>,
    lobbies: Arc<DashMap<String, Lobby>>,
    client_id: &Uuid,
    action: ActionServerToClient,
) {
    let client = clients.get(client_id).expect("Client does not exist");

    if client.lobby.is_none() {
        return;
    }

    let lobby_code = client.lobby.as_ref().unwrap();
    let lobby = lobbies.get(lobby_code).expect("Lobby does not exist");

    let host = clients
        .get(lobby.host.as_ref().unwrap())
        .expect("Host does not exist");

    let guests = lobby
        .guests
        .iter()
        .map(|g| clients.get(g).expect("Client does not exist"));

    for client in iter::once(host).chain(guests) {
        client.send_action(&action).await;
    }
}

pub fn username_action(clients: Arc<DashMap<Uuid, Client>>, client_id: &Uuid, username: String) {
    let mut client = clients.get_mut(client_id).unwrap();
    client.username = username;
}

pub fn create_lobby_action(
    clients: Arc<DashMap<Uuid, Client>>,
    lobbies: Arc<DashMap<String, Lobby>>,
    client_id: &Uuid,
    game_mode: String,
) {
    let game_mode: GameMode = game_mode.try_into().unwrap_or_default();
    let lobby = Lobby::new(Some(*client_id)).with_gamemode(game_mode);
    let mut client = clients.get_mut(client_id).unwrap();

    client.lobby = Some(lobby.code.clone());
    lobbies.insert(lobby.code.clone(), lobby);
}

pub fn join_lobby_action(lobbies: Arc<DashMap<String, Lobby>>, client_id: &Uuid, lobby_code: &str) {
    let mut lobby = lobbies.get_mut(lobby_code).expect("Lobby does not exist");

    if lobby.host.is_none() {
        lobby.host = Some(*client_id);
        return;
    }

    lobby.guests.push(*client_id);
}

pub fn leave_lobby_action(lobbies: Arc<DashMap<String, Lobby>>, client_id: &Uuid) {
    let lobby = lobbies
        .get(&client_id.to_string())
        .expect("Lobby does not exist or player is not in a lobby");

    if let Some(host) = lobby.host {
        if host == *client_id {
            lobbies.remove(&client_id.to_string());
        }
    }
}

pub async fn lobby_info_action(
    lobbies: Arc<DashMap<String, Lobby>>,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
) {
    let client = clients.get(client_id).expect("Client does not exist");
    if client.lobby.is_none() {
        return;
    }

    let lobby_code = client.lobby.as_ref().unwrap();
    let lobby = lobbies.get(lobby_code).expect("Lobby does not exist");

    if lobby.host.is_none() {
        return;
    }

    let host = clients
        .get(&lobby.host.unwrap())
        .expect("Host does not exist");

    let mut guests = lobby
        .guests
        .iter()
        .map(|g| clients.get(g).expect("Client does not exist"));

    // TODO: Just one player for now, should work with more
    let guest = guests.next();

    let mut action = ActionServerToClient::LobbyInfo {
        host: host.username.clone(),
        // TODO: Send every players' username
        guest: guest.map(|g| g.username.clone()),
        is_host: true,
    };

    host.send_action(&action).await;

    if let ActionServerToClient::LobbyInfo {
        host: _,
        guest: _,
        ref mut is_host,
    } = action
    {
        *is_host = false;
    }

    for guest in guests {
        guest.send_action(&action).await;
    }
}

pub async fn stop_game_action(
    lobbies: Arc<DashMap<String, Lobby>>,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
) {
    let action = ActionServerToClient::StopGame;
    broadcast_action(clients, lobbies, client_id, action).await;
}

pub fn generate_seed() -> String {
    const CHARSET: &str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const CODE_LENGTH: usize = 5;

    let mut rng = rand::thread_rng();

    let code: String = (0..CODE_LENGTH)
        .map(|_| {
            let idx = rng.gen_range(0..CHARSET.len());
            CHARSET.chars().nth(idx).unwrap()
        })
        .collect();

    code
}

pub async fn start_game_action(
    lobbies: Arc<DashMap<String, Lobby>>,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
) {
    let client = clients.get(client_id).expect("Client does not exist");
    if client.lobby.is_none() {
        return;
    }

    let lobby = lobbies
        .get(client.lobby.as_ref().unwrap())
        .expect("Lobby does not exist");

    // Only allow the client to start the game
    if lobby.host.unwrap() != *client_id {
        return;
    }

    let lives = if let Some(starting_lives) = lobby.options.get("starting_lives") {
        starting_lives.parse::<i32>().unwrap()
    } else {
        GAME_MODES
            .get()
            .unwrap()
            .get(&lobby.game_mode)
            .unwrap()
            .starting_lives
    };

    let different_seeds = lobby
        .options
        .get("different_seeds")
        .map(|s| *s == "true")
        .unwrap_or(false);

    let action = ActionServerToClient::StartGame {
        deck: "c_multiplayer_1".to_string(),
        stake: None,
        seed: if different_seeds {
            None
        } else {
            Some(generate_seed().to_string())
        },
    };
    broadcast_action(
        Arc::clone(&clients),
        Arc::clone(&lobbies),
        client_id,
        action,
    )
    .await;

    let host = clients
        .get_mut(lobby.host.as_ref().unwrap())
        .expect("Host does not exist");

    let guests = lobby
        .guests
        .iter()
        .map(|g| clients.get_mut(g).expect("Client does not exist"));

    // Set players lives
    for mut player in iter::once(host).chain(guests) {
        player.lives = lives;
    }
}

pub async fn action_version(
    client_version: &str,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
) {
    if client_version != VERSION {
        let client = clients.get(client_id).expect("Client does not exist");
        let action = ActionServerToClient::Error {
            message: format!("WARN: Server expecting version {}", VERSION),
        };

        client.send_action(&action).await;
    }
}

pub async fn action_ready_blind(
    lobbies: Arc<DashMap<String, Lobby>>,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
) {
    let mut client = clients.get_mut(client_id).expect("Client does not exist");
    if client.lobby.is_none() {
        return;
    }
    client.is_ready = true;

    let lobby = lobbies
        .get(client.lobby.as_ref().unwrap())
        .expect("Lobby does not exist");

    let players = iter::once(lobby.host.as_ref().unwrap())
        .chain(lobby.guests.iter())
        .map(|g| clients.get_mut(g).expect("Client does not exist"))
        .collect::<Vec<_>>();

    let all_ready = players.iter().all(|c| c.is_ready);
    if all_ready {
        let action = ActionServerToClient::StartBlind;
        broadcast_action(
            Arc::clone(&clients),
            Arc::clone(&lobbies),
            client_id,
            action,
        )
        .await;
    }

    for mut player in players {
        player.is_ready = false;
    }
}

pub fn action_unready_blind(clients: Arc<DashMap<Uuid, Client>>, client_id: &Uuid) {
    let mut client = clients.get_mut(client_id).expect("Client does not exist");
    client.is_ready = false;
}

pub async fn action_play_hand(
    lobbies: Arc<DashMap<String, Lobby>>,
    clients: Arc<DashMap<Uuid, Client>>,
    client_id: &Uuid,
    score: i32,
    hands_left: i32,
) {
    let mut client = clients.get_mut(client_id).expect("Client does not exist");
    if client.lobby.is_none() {
        return;
    }
    client.score = score;
    client.hands_left = hands_left;

    let lobby = lobbies
        .get(client.lobby.as_ref().unwrap())
        .expect("Lobby does not exist");

    let players = iter::once(lobby.host.as_ref().unwrap())
        .chain(lobby.guests.iter())
        .map(|g| clients.get_mut(g).expect("Client does not exist"))
        .filter(|p| p.id != *client_id)
        .collect::<Vec<_>>();

    let action = ActionServerToClient::EnemyInfo { score, hands_left };
    for player in players {
        player.send_action(&action).await;
    }
}
