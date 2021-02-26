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
