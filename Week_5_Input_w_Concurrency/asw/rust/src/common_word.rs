use std::collections::HashMap;

pub fn most_common_word(s: &str) -> Option<&str> {
    let mut counts = HashMap::new();

    for word in s.split_whitespace() {
        let count = counts.entry(word).or_insert(0);
        *count += 1;
    }

    match counts.iter().max_by_key(|x| x.1) {
        Some(result) => Some(result.0),
        None => None,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let s = "one two three one";
        assert_eq!(most_common_word(s), Some("one"));
    }

    #[test]
    fn it_handles_empty_string() {
        let s = "";
        assert_eq!(most_common_word(s), None);
    }

    #[test]
    fn it_handles_single_space() {
        let s = " ";
        assert_eq!(most_common_word(s), None);
    }
}
