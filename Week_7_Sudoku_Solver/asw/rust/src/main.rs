use std::io;

use sudoku::Board;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut board = Board::from_reader(&mut io::stdin())?;
    println!("{}", board);
    sudoku::solver::solve(&mut board)?;
    print!("{}", board);
    Ok(())
}
