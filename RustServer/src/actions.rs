use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
#[serde(tag = "action")]
#[serde(rename_all = "camelCase")]
pub enum ActionServerToClient {
    Connected,
    Error {
        message: String,
    },
    JoinedLobby {
        code: String,
    },
    #[serde(rename_all = "camelCase")]
    LobbyInfo {
        host: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        guest: Option<String>,
        is_host: bool,
    },
    StopGame,
    StartGame,
    StartBlind,
    WinGame,
    LoseGame,
    GameInfo {
        #[serde(skip_serializing_if = "Option::is_none")]
        small: Option<String>,
        #[serde(skip_serializing_if = "Option::is_none")]
        big: Option<String>,
        #[serde(skip_serializing_if = "Option::is_none")]
        boss: Option<String>,
    },
    PlayerInfo {
        lives: i32,
    },
    #[serde(rename_all = "camelCase")]
    EnemyInfo {
        score: i32,
        hands_left: i32,
    },
    EndPvP {
        lost: bool,
    },
    LobbyOptions,
    Version,
}

#[derive(Serialize, Deserialize)]
#[serde(tag = "action")]
#[serde(rename_all = "camelCase")]
pub enum ActionClientToServer {
    Username {
        username: String,
    },
    #[serde(rename_all = "camelCase")]
    CreateLobby {
        game_mode: String,
    },
    JoinLobby {
        code: String,
    },
    LeaveLobby,
    LobbyInfo,
    StopGame,
    StartGame,
    ReadyBlind,
    UnreadyBlind,
    #[serde(rename_all = "camelCase")]
    PlayHand {
        score: i32,
        hands_left: i32,
    },
    GameInfo,
    PlayerInfo,
    EnemyInfo,
    FailRound,
    SetAnte {
        ante: i32,
    },
    Version {
        version: String,
    },
}

#[derive(Serialize, Deserialize)]
#[serde(tag = "action")]
#[serde(rename_all = "camelCase")]
pub enum ActionUtility {
    KeepAlive,
    KeepAliveAck,
}

#[derive(Serialize, Deserialize)]
#[serde(untagged)]
pub enum Action {
    ServerToClient(ActionServerToClient),
    ClientToServer(ActionClientToServer),
    Utility(ActionUtility),
}
