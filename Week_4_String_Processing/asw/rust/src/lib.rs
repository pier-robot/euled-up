pub mod first_word {

    pub fn first_word1(s: &str) -> String {
        let mut result = String::new();

        for char in s.chars() {
            if char == ' ' {
                break;
            }
            result.push(char);
        }

        result
    }

    pub fn first_word2(s: &str) -> &str {
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
}

pub mod common_word {

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
}

pub mod longest_line {
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
}

pub mod character_groups {
    pub fn character_groups(s: &str) -> String {
        let mut result = String::new();

        let mut cur_char: Option<char> = None;
        let mut offset = 0;
        for (i, char) in s.chars().enumerate() {
            if Some(char) != cur_char {
                if result.len() > 0 {
                    result.push_str(", ");
                }
                result.push_str(&s[offset..i]);
                cur_char = Some(char);
                offset = i;
            }
        }

        if result.len() > 0 {
            result.push_str(", ");
        }
        result.push_str(&s[offset..s.len()]);

        result
    }

    #[cfg(test)]
    mod test {
        use super::*;

        #[test]
        fn it_works() {
            let s = "hello old wool";
            assert_eq!(character_groups(s), "h, e, ll, o,  , o, l, d,  , w, oo, l");
        }

        #[test]
        fn it_handles_empty_string() {
            let s = "";
            assert_eq!(character_groups(s), "");
        }

        #[test]
        fn it_handles_single_char() {
            let s = "aaa";
            assert_eq!(character_groups(s), "aaa");
        }
    }
}

pub mod substring {
    use unicode_segmentation::UnicodeSegmentation;

    pub fn substring(s: &str, start: usize, end: usize) -> &str {
        let mut iter = s.graphemes(true);
        let mut offset = 0;
        for _ in 0..start {
            match iter.next() {
                Some(x) => offset += x.len(),
                None => break,
            }
        }

        let mut end_offset = offset;
        for _ in start..end {
            match iter.next() {
                Some(x) => end_offset += x.len(),
                None => break,
            }
        }

        &s[offset..end_offset]
    }

    #[cfg(test)]
    mod test {
        use super::*;

        #[test]
        fn stdlib_works() {
            let s = String::from("💕😘💘🥰🇨🇦");
            // Unicode is weird
            assert_eq!(s.get(0..2), None);
            assert_eq!(s.get(0..4), Some("💕"));
            assert_eq!(s.get(4..16), Some("😘💘🥰"));
        }

        #[test]
        fn it_works() {
            let s = String::from("💕😘💘🥰🇨🇦");
            assert_eq!(substring(&s, 0, 1), "💕");
            assert_eq!(substring(&s, 1, 4), "😘💘🥰");
        }
    }
}
