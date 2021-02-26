use std::{env,fs};

fn main() {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let contents = fs::read_to_string(filename)
        .expect("Unable to read file");

    println!("{}", contents);
}
