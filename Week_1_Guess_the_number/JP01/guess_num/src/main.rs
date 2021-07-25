use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Guess the number!");

    // Create a random secret number between 1 and 100
    let secret_number = rand::thread_rng().gen_range(1..101);

    // loop until the user gets the correct answer
    loop {
        println!("Please input your guess.");

        // create a new mutable string to store the user's guess
        let mut guess = String::new();
        // read user input from stdin, if there's an error, handle it
        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        // attempt to cast the user input to an int
        let guess: u32 = match guess.trim().parse() {
            // if parse returns Ok, then assign the guess to num
            Ok(num) => num,

            // otherwise error and let the user try again
            Err(_) => {
                println!("Enter a valid integer between 1 and 100!\n");
                continue;
            }
        };

        println!("You guessed: {}", guess);

        // match the user guess with the secret number
        match guess.cmp(&secret_number) {
            // the cmp function returns an enum Ordering::XYZ
            // if the enum matches any of these then do something.
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
