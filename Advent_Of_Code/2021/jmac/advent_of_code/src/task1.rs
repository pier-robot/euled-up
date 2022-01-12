// Task 1: Count the number of times a depth measurement increases from the previous measurement.
// https://adventofcode.com/2021/day/1/input

use crate::utils;

pub fn run() {
    let input: Vec<i32> = utils::get_inputs("inputs/input1.txt");
    part1(&input);
    part2(&input);
}

fn part1(input: &Vec<i32>) {
    // Increment a counter if the number is greater than the previous one.
    let mut count = 0;
    for i in 1..input.len() {
        if input[i] > input[i - 1] {
            count += 1;
        }
    }
    println!("Depth Changes: {}", count);
}

fn part2(input: &Vec<i32>) {
    let mut count = 0;

    // create a list of data window summed values
    let sums: Vec<i32> = input
        .windows(3)
        .map(|win| win.to_vec().iter().sum())
        .collect();

    // Increment a counter if the sum of the data window is greater than sum of the previous
    for i in 1..sums.len() {
        if sums[i] > sums[i - 1] {
            count += 1;
        }
    }
    println!("Windowed Depth Changes: {}", count);
}
