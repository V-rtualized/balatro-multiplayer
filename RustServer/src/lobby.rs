use dashmap::DashMap;
use rand::Rng;
use uuid::Uuid;

#[derive(Debug, PartialEq, Eq, Hash)]
pub enum GameMode {
    Attrition,
    Draft,
}

impl ToString for GameMode {
    fn to_string(&self) -> String {
        match self {
            GameMode::Attrition => "attrition".to_string(),
            GameMode::Draft => "draft".to_string(),
        }
    }
}

impl TryFrom<&str> for GameMode {
    type Error = ();

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        match value {
            "attrition" => Ok(GameMode::Attrition),
            "draft" => Ok(GameMode::Draft),
            _ => Err(()),
        }
    }
}

impl TryFrom<String> for GameMode {
    type Error = ();

    fn try_from(value: String) -> Result<Self, Self::Error> {
        GameMode::try_from(value.as_str())
    }
}

impl Default for GameMode {
    fn default() -> Self {
        GameMode::Attrition
    }
}

pub struct Lobby {
    pub code: String,
    pub host: Option<Uuid>,
    pub guests: Vec<Uuid>,
    pub game_mode: GameMode,
    pub options: DashMap<String, String>,
}

pub fn generate_lobby_code() -> String {
    const CHARSET: &'static str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
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

impl Lobby {
    pub fn new(host: Option<Uuid>) -> Self {
        let mut lobby = Self::default();
        lobby.host = host;

        lobby
    }

    pub fn with_gamemode(mut self, game_mode: GameMode) -> Self {
        self.game_mode = game_mode;
        self
    }
}

impl Default for Lobby {
    fn default() -> Self {
        Self {
            code: generate_lobby_code(),
            host: None,
            guests: Vec::new(),
            game_mode: GameMode::Attrition,
            options: DashMap::new(),
        }
    }
}
