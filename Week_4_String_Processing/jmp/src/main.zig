const std = @import("std");

fn printFirstWord(string: []const u8) void {
    std.debug.print("First Word:\n", .{});
    // TODO, replace with word slicer
    var splits = std.mem.split(string, " ");
    var word = splits.next() orelse {
        std.debug.print(" Nothing in {s}\n", .{string});
        return;
    };
    std.debug.print("{s}\n", .{word});
}

fn printMostCommonWords(string: []const u8) void {
    // TODO, implement after word slicer
}

fn printLongestLines(string: []const u8) void {

    const allocator = std.heap.page_allocator;
    
    std.debug.print("Longest Lines:\n", .{});
    var list = std.ArrayList([]const u8).init(allocator);

    defer list.deinit();

    var slices = std.mem.tokenize(string, "?!.");
    var slice = slices.next() orelse {
        std.debug.print(" Nothing in {s}\n", .{string});
        return;
    };

    var longest: usize = 0;
    while (true) {
        list.append(slice) catch unreachable;
        longest = std.math.max(longest, slice.len);
        slice = slices.next() orelse {
            break;
        };
    }

    for (list.items) |item| {
        if (item.len == longest) {
            std.debug.print("{s}\n", .{item});
        }
    }
}

fn printCharacterGroups(string: []const u8) void {

    var i: usize = 0;
    var last_ch: u8 = undefined;
    std.debug.print("Character Groups:\n", .{});
    var ch: u8 = undefined;
    while ( i < string.len ) : (i+=1) {
        ch = string[i];
        if ( i!=0 and last_ch != ch) { // and std.ascii.isAlpha(ch)) {
            std.debug.print(", ", .{});
        }
        std.debug.print("{c}", .{ch});
        last_ch = ch;
    }
    std.debug.print("\n", .{});
}

fn printSubString(string: []const u8, start: usize, end: usize) void {
    std.debug.print("Sub String:\n", .{});
    if ( start < end and end < string.len ) {
        std.debug.print("{s}\n", .{string[start..end]});
    } else {
        std.debug.print("Invalid range\n", .{});
    }
}

fn printWithReplacement(string: []const u8, buf: []const u8, replace: []const u8) void {
    
    // we need to allocate space for the replacement string
    const allocator = std.heap.page_allocator;
    // to know the size to allocate to, we could either over allocate
    // 1- by finding the max the string could grow by. 
    //    (interesting challenge)
    // 2- loop through the string and calculate directly
    var replacement_size = std.mem.replacementSize(u8, string, buf, replace);
    var replaced = allocator.alloc(u8, replacement_size) catch {
        std.debug.print("Unable to allocate memory\n", .{});
        return;
    };
    defer allocator.free(replaced);
    _ = std.mem.replace(u8, string, buf, replace, replaced);
    std.debug.print("With Replacement:\n", .{});
    std.debug.print("{s}\n", .{replaced});
}


pub fn main() anyerror!void {
    const string = "All your codebase are belong to us.";
    std.debug.print("String:\n{s}\n", .{string});
    printFirstWord(string);
    printCharacterGroups(string);
    printLongestLines(string);
    printSubString(string, 2, 5);
    printWithReplacement(string, "code", "");

    std.debug.print("\n--------------------------------\n\n", .{});

    const string2 = "Hi!";
    std.debug.print("String:\n{s}\n", .{string2});
    printFirstWord(string2);
    printCharacterGroups(string2);
    printLongestLines(string2);
    printSubString(string2, 2, 5);
    printWithReplacement(string2, "!", "?");
    
    std.debug.print("\n--------------------------------\n\n", .{});

    const string3 =
\\ # String Shenanigans
\\ 
\\ This week is a set of small string processing challenges to get us used to using string and text in our chosen languages. Thanks to Jim for this idea!
\\ Get the first word in a string.
\\ Count the most common words in a string.
\\ Output the longest line in a string.
;

    std.debug.print("String:\n{s}\n", .{string3});
    printFirstWord(string3);
    printCharacterGroups(string3);
    printLongestLines(string3);
    printSubString(string3, 2, 5);
    printWithReplacement(string3, "!", "?");
}



// # String Shenanigans
// 
// This week is a set of small string processing challenges to get us used to using string and text in our chosen languages. Thanks to Jim for this idea!
// * Get the first word in a string.
// * Count the most common words in a string.
// * Output the longest line in a string.
//   * Bonus: Output all of the longest lines if there's a tie.
// * Output groups of characters as they appear in a string. So "hello old wool" would be output as "h, e, ll, o, , o, l, d, , w, oo, l".
// * Get the substring of a string.
// * Replace all occurrences of a character in a string with another.
//   * Bonus: Allow the replacement to be a string rather than a character. The replacement string can be of any length.
// * Match a string against a regex pattern (Usage of libraries is allowed!)
// * Substitute part of a string using a regex pattern (Usage of libraries is allowed!)
// 
// Hard mode (these may not apply to all of the above problems, and may not apply to your chosen language!):
// * Be wary of the encoding of the strings in the above problems (ie support unicode). Try with UTF-8 and UTF-16 encodings.
// * Do not use numerical comparisons in the above problems. Using equality is okay, but do not compare the length of a string.
// * Do not use lists in the above problems.
// * Do not use arithmetic operators in the above problems. (So no ++ or i += 1!).
// 
// "Just for Jim" (a separate problem to choose from if you want something bigger): 
// * Implement one or more edit distance algorithms as described here: https://en.wikipedia.org/wiki/Edit_distance
// 
// We like this one because it covers:
// * How to use strings and text.
// * Calling functions.
// * Using maps/dicts.
