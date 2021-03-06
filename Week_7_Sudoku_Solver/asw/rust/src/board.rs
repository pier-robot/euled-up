use std::fmt;
use std::io::Read;
use std::marker::Copy;
use std::ops::{Index, IndexMut};

#[derive(Clone, Copy, Debug)]
pub struct Board([[u8; 9]; 9]);

impl Board {
    pub fn from_reader<T: Read>(reader: &mut T) -> Result<Board, Box<dyn std::error::Error>> {
        let mut board: Board = Board([[0; 9]; 9]);
        for row in &mut board.0 {
            reader.read_exact(row)?;
        }
        for row in &mut board.0 {
            for cell in row {
                if ('0' as u8) > *cell || ('9' as u8) < *cell {
                    return Err(From::from(format!("Invalid value from stdin: {}", cell)));
                }
                *cell -= '0' as u8;
            }
        }
        Ok(board)
    }

    pub fn is_solved(&self) -> bool {
        for row in self.0.iter() {
            for cell in row {
                if *cell == 0 {
                    return false;
                }
            }
        }
        true
    }
}

impl fmt::Display for Board {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", format_board(*self))
    }
}

impl Index<usize> for Board {
    type Output = [u8; 9];

    fn index(&self, i: usize) -> &[u8; 9] {
        &self.0[i]
    }
}

impl IndexMut<usize> for Board {
    fn index_mut(&mut self, i: usize) -> &mut [u8; 9] {
        &mut self.0[i]
    }
}

fn format_board(board: Board) -> String {
    let mut result = String::with_capacity(9 * 9 * 2 + 9 * 2 + 18 * 2);

    for box_row in 0..3 {
        for row in 0..3 {
            for box_col in 0..3 {
                for col in 0..3 {
                    let value = board.0[box_row * 3 + row][box_col * 3 + col];
                    if value == 0 {
                        result.push_str("  ");
                    } else {
                        result.push_str(&format!("{} ", value));
                    }
                }
                if box_col != 2 {
                    result.push_str("| ");
                }
            }
            result.push('\n');
        }
        if box_row != 2 {
            result.push_str("------+-------+------\n");
        }
    }
    result
}

#[derive(Clone, Copy, Debug)]
pub struct Coord {
    pub row: usize,
    pub col: usize,
}

#[derive(Debug)]
pub struct BoxCells {
    row: usize,
    col: usize,
    max_row: usize,
    max_col: usize,
}

impl BoxCells {
    fn new(box_: Coord) -> BoxCells {
        let row = box_.row * 3;
        let col = box_.col * 3;
        BoxCells {
            row,
            col,
            max_row: row + 3,
            max_col: col + 3,
        }
    }
}

impl Iterator for BoxCells {
    type Item = Coord;

    fn next(&mut self) -> Option<Coord> {
        for row in self.row..self.max_row {
            for col in self.col..self.max_col {
                let result = Coord { row, col };
                self.col += 1;
                return Some(result);
            }
            self.row += 1;
            self.col -= 3;
        }
        None
    }
}

pub fn box_cells(box_: Coord) -> BoxCells {
    BoxCells::new(box_)
}

pub fn box_from_cell(cell: Coord) -> Coord {
    Coord {
        row: cell.row / 3,
        col: cell.col / 3,
    }
}
