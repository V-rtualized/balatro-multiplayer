use std::net::SocketAddr;
use uuid::Uuid;

pub struct Client {
    pub id: Uuid,
    pub address: SocketAddr,
    pub username: String,
    pub lobby: Option<String>,
    pub is_ready: bool,
    pub lives: i32,
    pub score: i32,
    pub hands_left: i32,
}

impl Client {
    pub fn new(id: Uuid, address: SocketAddr) -> Self {
        Self {
            id,
            address,
            username: "Guest".to_string(),
            lobby: None,
            is_ready: false,
            lives: 4,
            score: 0,
            hands_left: 4,
        }
    }
}
