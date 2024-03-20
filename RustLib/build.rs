use std::path::Path;

fn main() {
    // We only link with lua51 if we're using mingw
    let target = std::env::var("TARGET").unwrap();
    if target == "x86_64-pc-windows-gnu" {
        if !Path::exists(Path::new("./lua/lua51.dll")) {
            panic!(
                "Please add the lua51.dll to the lua folder (if it doesn't exist add one next to src) when compiling for the mingw target"
            );
        }

        println!("cargo:rustc-link-search=./lua");
        println!("cargo:rustc-link-lib=lua51");
    }
}
