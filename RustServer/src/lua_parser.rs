use crate::actions::ActionClientToServer;
use anyhow::{Error, Result};
use regex::Regex;
use std::collections::HashMap;
use tracing::info;

pub fn action_from_string(action_string: &str) -> Result<ActionClientToServer> {
    let re = Regex::new(r"(action:[^,\r]+)(?:,([^,]+:[^,\n\r]+))*\r?\n")?;
    let captures = re
        .captures(action_string)
        .ok_or(Error::msg("Could not find captures in regex"))?;

    let pairs = captures.iter().skip(1);
    let mut properties = HashMap::new();

    for pair in pairs {
        if pair.is_none() {
            continue;
        }

        let pair = pair.ok_or(Error::msg("Could not find pairs in regex"))?;
        let pair_str = pair.as_str();
        let pair_split = pair_str.split(':').collect::<Vec<&str>>();
        let key = pair_split[0];
        let value = pair_split[1];

        properties.insert(key, value);
    }

    let action_name = *properties
        .get("action")
        .ok_or(Error::msg("Could not parse action in message"))?;
    info!(?action_name, "action_from_string");

    match action_name {
        "username" => {
            let username = *properties
                .get("username")
                .ok_or(Error::msg("Could not find username in message"))?;

            Ok(ActionClientToServer::Username {
                username: username.to_string(),
            })
        }
        "createLobby" => {
            let game_mode = *properties
                .get("gameMode")
                .ok_or(Error::msg("Could not find gameMode in message"))?;

            Ok(ActionClientToServer::CreateLobby {
                game_mode: game_mode.to_string(),
            })
        }
        "joinLobby" => {
            let code = *properties
                .get("code")
                .ok_or(Error::msg("Could not find code in message"))?;

            Ok(ActionClientToServer::JoinLobby {
                code: code.to_string(),
            })
        }
        "leaveLobby" => Ok(ActionClientToServer::LeaveLobby),
        "lobbyInfo" => Ok(ActionClientToServer::LobbyInfo),
        "stopGame" => Ok(ActionClientToServer::StopGame),
        "startGame" => Ok(ActionClientToServer::StartGame),
        "readyBlind" => Ok(ActionClientToServer::ReadyBlind),
        "unreadyBlind" => Ok(ActionClientToServer::UnreadyBlind),
        "playHand" => {
            let score = *properties
                .get("score")
                .ok_or(Error::msg("Could not find username in message"))?;
            let hands_left = *properties
                .get("handsLeft")
                .ok_or(Error::msg("Could not find username in message"))?;

            Ok(ActionClientToServer::PlayHand {
                score: score.parse()?,
                hands_left: hands_left.parse()?,
            })
        }
        "gameInfo" => Ok(ActionClientToServer::GameInfo),
        "playerInfo" => Ok(ActionClientToServer::PlayerInfo),
        "enemyInfo" => Ok(ActionClientToServer::EnemyInfo),
        "failRound" => Ok(ActionClientToServer::FailRound),
        "setAnte" => {
            let ante = *properties
                .get("ante")
                .ok_or(Error::msg("Could not find username in message"))?;

            Ok(ActionClientToServer::SetAnte {
                ante: ante.parse()?,
            })
        }
        "version" => {
            let version = *properties
                .get("version")
                .ok_or(Error::msg("Could not find username in message"))?;

            Ok(ActionClientToServer::Version {
                version: version.to_string(),
            })
        }
        action => Err(Error::msg(format!("Unknown action: {}", action))),
    }
}

////////////////////////////////////////////////////////////////////////////////

#[cfg(test)]
mod test {
    use super::*;
    use std::sync::Once;

    static INIT: Once = Once::new();

    pub fn initialize() {
        INIT.call_once(|| {
            tracing_subscriber::fmt::init();
        });
    }

    #[test]
    fn test_enemy_info() {
        initialize();

        let enemy_info: Result<ActionClientToServer> = action_from_string("action:enemyInfo\n");

        assert!(enemy_info.is_ok());
        assert_eq!(enemy_info.unwrap(), ActionClientToServer::EnemyInfo);
    }

    #[test]
    fn test_username() {
        initialize();

        let username = action_from_string("action:username,username:foo\n");
        assert!(username.is_ok());
        assert_eq!(
            username.unwrap(),
            ActionClientToServer::Username {
                username: "foo".to_string()
            }
        );
    }
}
