use std::fmt;
use std::fs;
use std::str::FromStr;

// The return type T needs to implement the FromStr and fmt::Debug
pub fn get_inputs<T>(input_path: &str) -> Vec<T>
where
    T: FromStr,
    <T as FromStr>::Err: fmt::Debug,
{
    let input: String =
        fs::read_to_string(input_path).expect("Something went wrong reading the file");
    let inputs: Vec<T> = input.split("\n").map(|i| i.parse::<T>().unwrap()).collect();
    inputs
}
