use rand::Rng;
use uuid::Uuid;

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

pub struct Lobby {
    pub code: String,
    pub host: Option<Uuid>,
    pub guests: Vec<Uuid>,
    pub game_mode: GameMode,
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
}

impl Default for Lobby {
    fn default() -> Self {
        Self {
            code: generate_lobby_code(),
            host: None,
            guests: Vec::new(),
            game_mode: GameMode::Attrition,
        }
    }
}
