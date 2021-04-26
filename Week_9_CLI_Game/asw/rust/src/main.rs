use std::collections::HashMap;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;

use serde::{Deserialize,Serialize};
use serde_json::Value;

#[derive(Serialize, Deserialize, Debug)]
struct Description {
    default: String,
    #[serde(default)]
    conditionals: HashMap<String, String>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Room {
    description: Description,
    #[serde(default)]
    items: Vec<Value>,
    #[serde(default)]
    exits: HashMap<String, Exit>,
    #[serde(default)]
    npcs: Vec<Npc>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Exit {
    id: String,
    name: String,
    status: String,
    details: String,
}

#[derive(Serialize, Deserialize, Debug)]
struct Npc {
    id: String,
    name: String,
    details: String,
    stats: Stats,
}

#[derive(Serialize, Deserialize, Debug)]
struct Stats {
    hp: i32,
    damage: i32,
}

#[derive(Serialize, Deserialize, Debug)]
struct Node {
    id: String,
    name: String,
    north: Option<String>,
    south: Option<String>,
    east: Option<String>,
    west: Option<String>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Game {
    graph: Vec<Node>,
    #[serde(rename = "win-condition")]
    win_condition: Value,
    #[serde(rename = "lose-condition")]
    lose_condition: Value,
    #[serde(default)]
    rooms: HashMap<String, Room>,
}

fn new_game() -> Result<Game, Box<dyn Error>> {
    let file = File::open("game.json")?;
    let reader = BufReader::new(file);
    let game = serde_json::from_reader(reader)?;

    Ok(game)
}

fn main() -> Result<(), Box<dyn Error>> {
    let game = new_game()?;

    println!("{:#?}", game);

    let out_file = File::create("save.json")?;
    serde_json::to_writer_pretty(out_file, &game)?;
    Ok(())
}
