use crate::utils;

pub fn run() {
    let input_path = "inputs/input2.txt";
    let inputs: Vec<String> = utils::get_inputs(input_path);
    part1(inputs);
    part2(inputs);

}

fn part1(inputs: Vec<String>) {
    // Calculate the Distance travelled and Depth achieved
    let mut distance = 0;
    let mut depth = 0;

    for input in inputs {
        // The format of input will be [direction, value] 
        let instruction: Vec<&str> = input.split(" ").collect();
        let direction = instruction[0];
        let value = instruction[1].parse::<i32>().unwrap();
        
        match direction {
            "forward" => distance += value,
            "up" => depth -= value, // going up will reduce depth and vice versa
            "down" => depth += value,
            _ => (), // Don't do anything
        }
    }

    println!("Part 1: {}", distance * depth);
}

fn part2(inputs: Vec<String>) {
    // Calculate the Distance travelled and Depth achieved
    let mut distance = 0;
    let mut depth = 0;
    let mut aim = 0;
    
    for input in inputs {
        // The format of input will be [direction, value] 
        let instruction: Vec<&str> = input.split(" ").collect();
        let direction = instruction[0];
        let value = instruction[1].parse::<i32>().unwrap();
        
        match direction {
            "forward" => {
                distance += value;
                depth += aim * value;
            },
            "up" => aim -= value, // going up will reduce depth and vice versa
            "down" => aim += value,
            _ => (), // Don't do anything
        }
    }
    println!("Part 2: {}", distance * depth);

}