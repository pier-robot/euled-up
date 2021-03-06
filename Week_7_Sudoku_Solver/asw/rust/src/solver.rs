use crate::board::Board;

mod candidate;
mod single_candidate;

pub fn solve(board: &mut Board) -> Result<(), Box<dyn std::error::Error>> {
    while !board.is_solved() {
        let mut found_candidate = false;
        for candidate in single_candidate::find_single_candidates(*board) {
            board[candidate.position.row][candidate.position.col] = candidate.value;
            found_candidate = true;
        }

        if !found_candidate {
            return Err(From::from("Cannot solve puzzle!"));
        }
    }

    Ok(())
}
