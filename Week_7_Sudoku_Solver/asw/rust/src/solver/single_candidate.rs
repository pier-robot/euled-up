use std::collections::HashSet;

use super::candidate::Candidate;
use crate::board::{self, Board, Coord};

#[derive(Debug)]
pub struct SingleCandidates {
    board: Board,
    row: usize,
    col: usize,
}

impl SingleCandidates {
    fn new(board: Board) -> SingleCandidates {
        SingleCandidates {
            board,
            row: 0,
            col: 0,
        }
    }
}

impl Iterator for SingleCandidates {
    type Item = Candidate;

    fn next(&mut self) -> Option<Candidate> {
        for row in self.row..9 {
            for col in self.col..9 {
                let value = match find_single_candidate(self.board, Coord { row, col }) {
                    Some(result) => result,
                    None => continue,
                };
                let result = Candidate {
                    position: Coord { row, col },
                    value,
                };

                self.row = row;
                self.col = col + 1;
                return Some(result);
            }
        }

        None
    }
}

fn find_single_candidate(board: Board, cell: Coord) -> Option<u8> {
    if board[cell.row][cell.col] != 0 {
        return None;
    }

    let mut candidates = HashSet::with_capacity(9);
    candidates.extend(1..10);

    for value in board[cell.row].iter() {
        candidates.remove(value);
    }

    for row_i in 0..9 {
        candidates.remove(&board[row_i][cell.col]);
    }

    let box_ = board::box_from_cell(cell);
    for cell in board::box_cells(box_) {
        candidates.remove(&board[cell.row][cell.col]);
    }

    if candidates.len() == 1 {
        return Some(*candidates.iter().next().unwrap());
    }

    None
}

pub fn find_single_candidates(board: Board) -> SingleCandidates {
    SingleCandidates::new(board)
}
