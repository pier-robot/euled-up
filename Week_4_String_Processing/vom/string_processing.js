function proper_split(input_string: string) {
    // Ensuring punctuation is properly handled
    return input_string.trim().split(/[\s,.!?:;]+/)
}

function first_word(input_string: string) {
    // Nothing to see here
    return proper_split(input_string)[0]
}

function most_common_word(input_string: string) {
    const sub_strings = proper_split(input_string)
    // Note that `word` in this initialization is an arbitary
    // identifier used for readability only
    let counts: {[word: string]: number} = {}

    // The following are 4 ways to do the same thing to show some variety:

    // Using for loop, if/else, and all braces...
    /*
    for (let i = 0; i < sub_strings.length; i++) {
        let word = sub_strings[i]
        if (!counts[word]) {
            counts[word] = 1
        }
        else {
            counts[word]++
        }
    }
    */

    // ...using for loop shorthand and if/else (aping Python)...
    /*
    for (let word of sub_strings)
        if (counts[word]) 
            counts[word] += 1
        else counts[word] = 1
    */

    // ...a forEach with an anonymous function and ternary...
    /*
    sub_strings.forEach(
        function(word) {
            counts[word] = counts[word] ? counts[word] + 1 : 1
        }
    )
    */
    // ...and a one-liner using pre-incrementing, a lambda, and falsy NaN
    // Note that if counts[word] was -1 this would evaluate incorrectly
    sub_strings.forEach(word => counts[word] = ++counts[word] || 1)

    // Declaring types is optional when it's implied:
    // `const count_values: number[]` isn't necessary here
    const count_values = Object.values(counts)
    const max_value = Math.max(...count_values)

    // Note the `===` rather than `==` as the latter uses coercion...
    // `"thing" == ["thing"]`  >> true
    // `"thing" === ["thing"]` >> false
    // TypeScript is a superset of JavaScript which was written in 10 days
    // and must maintain backward compatibility (see: internet)
    const most_common_words = Object.keys(counts).filter(
        word => counts[word] === max_value
    )
    return most_common_words
}

function longest_lines(input_string: string) {
    // Only splitting on `\n` for this one and not trimming
    const lines = input_string.split("\n")
    // Using the `reduce` method here to iterate over the list of items
    // and find the longest; it takes the first item in the list and places
    // it in the first variable, then iterates through the other items
    // in the second variable
    const longest_line = lines.reduce(
        (a, b) => a.length > b.length ? a : b
    )
    // Using `filter` gives all valid results, `find` would get the first
    const longest_lines = lines.filter(
        line => line.length == longest_line.length
    )
    return longest_lines
}

function groups_of_characters(input_string: string) {
    // With native regex support this is an exercise in writing a regex
    return input_string.match(/(.)\1*/g)
}

function get_substring(input_string: string, start: number, end: number) {
    // Slice method takes the first included index and first excluded index
    return input_string.slice(start, end)
}

function replace_substring(input_string: string, old_str: string, new_str: string) {
    // Need to construct a regex for a global search and replace as the replaceAll
    // method isn't fully supported (thanks IE)
    let old_regex = new RegExp(old_str, "g")
    return input_string.replace(old_regex, new_str)
}

const input = "hello old wool\nand wool of all old llamas\nbut not wool of bald sheep"

console.log(`input string:\n${input}`)
console.log(`first word:\n${first_word(input)}`)
console.log(`most common word:\n${most_common_word(input)}`)
console.log(`longest lines:\n${longest_lines(input)}`)
console.log(`grouped characters:\n${groups_of_characters(input)}`)
console.log(`substring 4:20:\n${get_substring(input, 4, 20)}`)
console.log(`replace old -> new:\n${replace_substring(input, "old", "new")}`)
