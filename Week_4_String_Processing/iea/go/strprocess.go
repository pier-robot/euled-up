package strprocess

import (
	"strings"
	"unicode"
)


func isSeparator(character rune) bool {
	return unicode.IsSpace(character) || unicode.IsPunct(character)
}

// GetFirst returns the first word of a given string.
func GetFirst(s string) string {
	split := strings.FieldsFunc(s, isSeparator)
	if len(split) > 0 {
		return split[0]
	}
	return ""
}


// CountWords, given a string, returns a map of the words
// in it and the amount of times they were repeated.
func CountWords(s string) map[string]int {
	var wordCounter = map[string]int{}
	split := strings.FieldsFunc(s, isSeparator)
	// equivalent to enumerate(list) in python
	for _, word := range split {
		// first var `_` is the value, 2nd is a boolean that
		// is true if the requested key `word` is in the map
		if _, found := wordCounter[word]; found {
			wordCounter[word] += 1
		} else {
			wordCounter[word] = 1
		}
	}
	return wordCounter
}


// Get the longest line(s) in a (multi)line string.
func LongestLines(s string) (result []string) {
	split := strings.Split(s, "\n")
	longestIndex := make([]int, 1)
	for index, line := range split {
		if index == 0 {
			longestIndex[0] = index
		} else if len(line) == len(split[longestIndex[0]]) {
			longestIndex = append(longestIndex, index)
		} else if len(line) > len(split[longestIndex[0]]) {
			longestIndex = longestIndex[:1]
			longestIndex[0] = index
		}
	}
	for _, index := range longestIndex {
		result = append(result, split[index])
	}
	return
}


// OutputCharGroups outputs groups of characters as they
// appear in the input string.
func OutputCharGroups(s string) string {
	result := make([]string, 0)
	curChar := ""
	for index, rune := range s {
		char := string(rune)
		if index == 0 {
			curChar = char
		} else if strings.Contains(curChar, char) {
			curChar += char
		} else {
			result = append(result, curChar)
			curChar = char
		}
		if index == len(s) -1 {
			result = append(result, curChar)
		}
	}
	return strings.Join(result, ", ")
}


// Get substring 'slice'.
func Substring(s string, first int, last int) string {
	return s[first:last]
}


// Replace all the instances of `oldstr` with `newstr` in given string.
func ReplaceSubstring(s string, oldstr, newstr string) string {
	return strings.ReplaceAll(s, oldstr, newstr)
}
