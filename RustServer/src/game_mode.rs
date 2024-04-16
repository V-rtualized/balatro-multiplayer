use crate::lobby::GameMode;
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use tokio::sync::OnceCell;

#[derive(Serialize, Deserialize, Debug, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct GameInfo {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub small: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub big: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub boss: Option<String>,
}

#[derive(Debug, PartialEq)]
pub struct GameModeData {
    pub starting_lives: i32,
    // Takes ante and options, returns GameInfo
    pub get_blind_from_ante: fn(i32, DashMap<String, String>) -> GameInfo,
}

pub static GAME_MODES: OnceCell<DashMap<GameMode, GameModeData>> = OnceCell::const_new();

pub async fn initialize_gamemodes() -> DashMap<GameMode, GameModeData> {
    let gamemodes = DashMap::new();
    gamemodes.insert(
        GameMode::Attrition,
        GameModeData {
            starting_lives: 4,
            get_blind_from_ante: |_ante, _options| GameInfo {
                small: None,
                big: None,
                boss: Some("bl_pvp".to_string()),
            },
        },
    );
    gamemodes.insert(
        GameMode::Draft,
        GameModeData {
            starting_lives: 2,
            get_blind_from_ante: |_ante, _options| GameInfo {
                small: Some("bl_pvp".to_string()),
                big: Some("bl_pvp".to_string()),
                boss: Some("bl_pvp".to_string()),
            },
        },
    );

    gamemodes
}
