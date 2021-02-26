#[allow(dead_code)]
fn first_word1(s: &str) -> String {
    let mut result = String::new();

    for char in s.chars() {
        if char == ' ' {
            break;
        }
        result.push(char);
    }

    result
}

#[allow(dead_code)]
fn first_word2(s: &str) -> &str {
    for (i, char) in s.chars().enumerate() {
        if char == ' ' {
            return &s[..i];
        }
    }

    s
}

pub fn first_word3(s: &str) -> &str {
    match s.split_whitespace().next() {
        Some(result) => result,
        None => &s[..0],
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_finds_first_word() {
        let s = String::from("one two three");
        assert_eq!(first_word1(&s), "one");
        assert_eq!(first_word2(&s), "one");
        assert_eq!(first_word3(&s), "one");
    }

    #[test]
    fn it_does_empty_word() {
        let s = "";
        assert_eq!(first_word1(&s), "");
        assert_eq!(first_word2(&s), "");
        assert_eq!(first_word3(&s), "");
    }

    #[test]
    fn it_does_space() {
        let s = " ";
        assert_eq!(first_word1(&s), "");
        assert_eq!(first_word2(&s), "");
        assert_eq!(first_word3(&s), "");
    }

    #[test]
    fn it_does_single_word() {
        let s = "word";
        assert_eq!(first_word1(&s), "word");
        assert_eq!(first_word2(&s), "word");
        assert_eq!(first_word3(&s), "word");
    }
}
