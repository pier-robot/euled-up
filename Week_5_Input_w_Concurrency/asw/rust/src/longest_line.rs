pub fn longest_line(s: &str) -> &str {
    match s.lines().max_by_key(|x| x.len()) {
        Some(result) => result,
        None => &s[..0],
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn it_works() {
        let s = "one\ntwotwo\nthreethree";
        assert_eq!(longest_line(s), "threethree");

        let s = "one\ntwotwotwo\nthree";
        assert_eq!(longest_line(s), "twotwotwo");
    }

    #[test]
    fn it_handles_empty_string() {
        let s = "";
        assert_eq!(longest_line(s), "");
    }

    #[test]
    fn it_handles_empty_lines() {
        let s = "\n\n\n";
        assert_eq!(longest_line(s), "");

        let s = "one\n\ntwotwo\n";
        assert_eq!(longest_line(s), "twotwo");
    }
}
