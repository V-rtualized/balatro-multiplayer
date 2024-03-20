use mlua::prelude::*;
use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::TcpListener,
    runtime::Runtime,
};

async fn main_thread_message_queue(ui_to_network_channel_pop: LuaFunction<'_>) -> LuaResult<()> {
    let requests_per_cycle = 25;
    loop {
        for _ in 0..requests_per_cycle {
            let msg = ui_to_network_channel_pop.call::<_, LuaAnyUserData>(())?;
            let msg = msg.borrow::<String>();

            if let Ok(msg) = msg {
                if msg.starts_with("action") {
                    // Networking.Client:send(msg .. "\n")
                } else if msg.as_str() == "connect" {
                    // Networking.connect()
                }
            } else {
                // If there are no more messages, yield
                tokio::task::yield_now().await;
            }
        }

        // Yield to the main thread
        tokio::task::yield_now().await;
    }
}

fn start_server(lua: &Lua, _: ()) -> LuaResult<()> {
    let rt = Runtime::new()?;
    rt.block_on(async {
        let listener = TcpListener::bind("127.0.0.1:25565").await?;

        loop {
            let (mut socket, _) = listener.accept().await?;

            socket.set_nodelay(true)?;
            tokio::spawn(async move {
                let mut buf = [0; 1024];

                // In a loop, read data from the socket and write the data back.
                loop {
                    let n = match socket.read(&mut buf).await {
                        // socket closed
                        Ok(n) if n == 0 => return,
                        Ok(n) => n,
                        Err(e) => {
                            println!("failed to read from socket; err = {:?}", e);
                            return;
                        }
                    };

                    // Write the data back
                    if let Err(e) = socket.write_all(&buf[0..n]).await {
                        println!("failed to write to socket; err = {:?}", e);
                        return;
                    }
                }
            });
        }
    })
}

#[mlua::lua_module]
fn balatro_multiplayer_rlib(lua: &Lua) -> LuaResult<LuaTable> {
    let exports = lua.create_table()?;
    exports.set("start_server", lua.create_function(start_server)?)?;

    Ok(exports)
}
