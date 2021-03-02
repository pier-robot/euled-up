use std::cmp::Ordering;
use std::error::Error;
use std::fmt::Display;
use std::ops::Sub;
use std::str::FromStr;

pub fn min_max<T: PartialOrd + FromStr + Display + Sub<Output = T> + Copy>(
    path: &str,
    id_col: usize,
    col_a: usize,
    col_b: usize,
) -> Result<((String, T), (String, T)), Box<dyn Error>> {
    let mut largest: Option<(String, T)> = None;
    let mut smallest: Option<(String, T)> = None;

    let mut reader = csv::Reader::from_path(path)?;
    for result in reader.records() {
        let record = result?;
        let row_id = &record[id_col];
        let val_a: T = match record[col_a].parse() {
            Ok(val) => val,
            Err(_) => continue,
        };
        let val_b: T = match record[col_b].parse() {
            Ok(val) => val,
            Err(_) => continue,
        };

        let diff: T = match val_a.partial_cmp(&val_b) {
            None => {
                return Err(From::from(format!(
                    "Cannot compare {} and {} for row {}",
                    val_a, val_b, row_id
                )))
            }
            Some(Ordering::Greater) => val_a - val_b,
            _ => val_b - val_a,
        };

        // Hmm this doesn't seem great..
        // The following doesn't work:
        // None | Some(cur) if cur.1 <= diff => Some((String::from(id), diff)),
        // But splitting it requires creating the value twice
        // and what's below requires a comment to clarify.
        largest = match largest {
            Some(cur) if cur.1 >= diff => Some(cur),
            // None or cur < diff
            _ => Some((String::from(row_id), diff)),
        };

        smallest = match smallest {
            Some(cur) if cur.1 <= diff => Some(cur),
            // None or cur < diff
            _ => Some((String::from(row_id), diff)),
        };
    }

    match smallest {
        Some(cur) => Ok((cur, largest.unwrap())),
        None => return Err(From::from("No valid records")),
    }
}
