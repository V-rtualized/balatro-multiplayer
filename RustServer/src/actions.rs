use serde::{Deserialize, Serialize};

use crate::game_mode::GameInfo;

#[derive(Serialize, Deserialize, Debug, PartialEq)]
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
    StartGame {
        deck: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        stake: Option<i32>,
        #[serde(skip_serializing_if = "Option::is_none")]
        seed: Option<String>,
    },
    StartBlind,
    WinGame,
    LoseGame,
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
    GameInfo(GameInfo),
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
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

#[derive(Serialize, Deserialize, Debug, PartialEq)]
#[serde(tag = "action")]
#[serde(rename_all = "camelCase")]
pub enum ActionUtility {
    KeepAlive,
    KeepAliveAck,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
#[serde(untagged)]
pub enum Action {
    ServerToClient(ActionServerToClient),
    ClientToServer(ActionClientToServer),
    Utility(ActionUtility),
}
