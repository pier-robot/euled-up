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
