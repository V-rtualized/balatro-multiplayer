use std::{net::SocketAddr, sync::Arc};
use tokio::{
    io::{AsyncWriteExt, BufReader},
    net::TcpStream,
    sync::Mutex,
};
use uuid::Uuid;

use crate::{actions::ActionServerToClient, lua_ser};

pub struct Client {
    pub id: Uuid,
    pub address: SocketAddr,
    pub socket: Arc<Mutex<BufReader<TcpStream>>>,
    pub username: String,
    pub lobby: Option<String>,
    pub is_ready: bool,
    pub lives: i32,
    pub score: i32,
    pub hands_left: i32,
}

impl Client {
    pub fn new(id: Uuid, address: SocketAddr, socket: Arc<Mutex<BufReader<TcpStream>>>) -> Self {
        Self {
            id,
            address,
            socket,
            username: "Guest".to_string(),
            lobby: None,
            is_ready: false,
            lives: 4,
            score: 0,
            hands_left: 4,
        }
    }

    pub async fn send_action(&self, action: &ActionServerToClient) {
        let mut socket = self.socket.lock().await;
        socket
            .write_all(lua_ser::to_string(action).unwrap().as_bytes())
            .await
            .unwrap();
    }
}