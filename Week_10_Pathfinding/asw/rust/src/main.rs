use std::error::Error;

use raylib::prelude::*;

const SCREEN_SIZE: i32 = 960;

fn read_grid(path: &str, size: usize) -> Result<Vec<Vec<u8>>, Box<dyn Error>>
{
    let mut grid = Vec::with_capacity(size);

    let mut reader = csv::ReaderBuilder::new()
        .has_headers(false)
        .from_path(path)?;
    for result in reader.records() {
        let mut row = Vec::<u8>::with_capacity(size);
        let record = result?;
        for field in record.iter() {
            row.push(field.parse()?);
        }
        grid.push(row);
    }

    Ok(grid)
}

fn draw_grid(grid: &[Vec<u8>], d: &mut RaylibDrawHandle) {
    // TODO: This type conversion isn't safe.
    let box_size = SCREEN_SIZE / (grid.len() as i32);

    for (i, row) in grid.iter().enumerate() {
        for (j, &value) in row.iter().enumerate() {
            let colour = if value == 0 { Color::BLACK } else {Color::WHITE};
            d.draw_rectangle((j as i32) * box_size, (i as i32) * box_size, box_size, box_size, colour);
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let (mut rl, thread) = raylib::init()
        .size(SCREEN_SIZE, SCREEN_SIZE)
        .build();
    rl.set_target_fps(60);

    let grid = read_grid("data/act1.csv", 20)?;

    while !rl.window_should_close() {
        let mut d = rl.begin_drawing(&thread);
        d.clear_background(Color::BLACK);
        draw_grid(&grid[..], &mut d)
    }

    Ok(())
}
