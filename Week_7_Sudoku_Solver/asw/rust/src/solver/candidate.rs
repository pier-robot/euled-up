use crate::board::Coord;

#[derive(Debug)]
pub struct Candidate {
    pub position: Coord,
    pub value: u8,
}
