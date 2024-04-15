use crate::actions::ActionClientToServer;
use regex::Regex;
use std::collections::HashMap;

pub fn action_from_string(action_string: &str) -> Result<ActionClientToServer, ()> {
    let re = Regex::new(r"(action:[^,]+)(?:,([^,]+:[^,\r]+))*\r?\n").unwrap();
    let captures = re.captures(action_string).unwrap();

    let pairs = captures.iter().skip(1);
    let mut properties = HashMap::new();

    for pair in pairs {
        if pair.is_none() {
            continue;
        }

        let pair = pair.unwrap();
        let pair_str = pair.as_str();
        let pair_split = pair_str.split(':').collect::<Vec<&str>>();
        let key = pair_split[0];
        let value = pair_split[1];

        properties.insert(key, value);
    }

    let action_name = *properties.get("action").unwrap();

    match action_name {
        "username" => {
            let username = *properties.get("username").unwrap();

            Ok(ActionClientToServer::Username {
                username: username.to_string(),
            })
        }
        "createLobby" => {
            let game_mode = *properties.get("gameMode").unwrap();

            Ok(ActionClientToServer::CreateLobby {
                game_mode: game_mode.to_string(),
            })
        }
        "joinLobby" => {
            let code = *properties.get("code").unwrap();

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
            let score = *properties.get("score").unwrap();
            let hands_left = *properties.get("handsLeft").unwrap();

            Ok(ActionClientToServer::PlayHand {
                score: score.parse().unwrap(),
                hands_left: hands_left.parse().unwrap(),
            })
        }
        "gameInfo" => Ok(ActionClientToServer::GameInfo),
        "playerInfo" => Ok(ActionClientToServer::PlayerInfo),
        "enemyInfo" => Ok(ActionClientToServer::EnemyInfo),
        "failRound" => Ok(ActionClientToServer::FailRound),
        "setAnte" => {
            let ante = *properties.get("ante").unwrap();

            Ok(ActionClientToServer::SetAnte {
                ante: ante.parse().unwrap(),
            })
        }
        "version" => {
            let version = *properties.get("version").unwrap();

            Ok(ActionClientToServer::Version {
                version: version.to_string(),
            })
        }
        _ => Err(()),
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

        let enemy_info = action_from_string("action:enemyInfo\n");
        assert_eq!(enemy_info, Ok(ActionClientToServer::EnemyInfo));
    }

    #[test]
    fn test_username() {
        initialize();

        let username = action_from_string("action:username,username:foo\n");
        assert_eq!(
            username,
            Ok(ActionClientToServer::Username {
                username: "foo".to_string()
            })
        );
    }
}
