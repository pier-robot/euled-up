use crate::utils;

pub fn run() {
    // we are expecting 12 bit numbers
    const WIDTH: usize = 12;

    let lines: Vec<i32> = utils::get_inputs("inputs/input3.txt");

    for line in lines {
        println!("{}", line);
    }
}
