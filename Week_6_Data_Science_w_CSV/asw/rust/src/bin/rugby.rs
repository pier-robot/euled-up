use data_science;
use std::process;

fn main() {
    match data_science::min_max::<f32>("../../data/rugby.csv", 0, 2, 12) {
        Ok((smallest, largest)) => {
            println!("Smallest: {} with {}", smallest.0, smallest.1);
            println!("Largest: {} with {}", largest.0, largest.1);
        }
        Err(err) => {
            println!("Error reading CSV: {}", err);
            process::exit(1);
        }
    }
}
