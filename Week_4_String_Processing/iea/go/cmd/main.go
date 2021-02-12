package main

import (
	"fmt"

	"strprocess"
)

const input = `hello old wool
and wool of all old llamas
but not wool of bald sheep`

func main() {
	fmt.Printf("input string: %s\n", input)
	fmt.Println("first word:", strprocess.GetFirst(input))
	fmt.Println("most common word:", strprocess.CountWords(input))
	fmt.Printf("longest lines: %#v\n", strprocess.LongestLines(input))
	fmt.Println("grouped characters:", strprocess.OutputCharGroups(input))
	fmt.Println("substring 4:20:", strprocess.Substring(input, 4, 20))
	fmt.Printf("replace old -> new: %s\n", strprocess.ReplaceSubstring(input, "old", "new"))
}
