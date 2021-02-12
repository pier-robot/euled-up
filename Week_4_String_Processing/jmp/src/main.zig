const std = @import("std");
const Allocator = std.mem.Allocator;

const FilterIterator = struct {

    buffer: []const u8,
    index: ?usize,
    filter: fn (c: u8) bool,

    pub fn next(self: *FilterIterator) ?[]const u8 {
        const start = self.index orelse return null;
        var offset: usize = start;

        while (offset < self.buffer.len) : (offset+=1) {
            if (self.filter(self.buffer[offset])) break;
        }

        // We did not find any matching filter char.
        if (offset == self.buffer.len) {
            self.index = null;
            return null;
        }
        
        var new_start = offset;
        
        while (offset < self.buffer.len) : (offset+=1) {
            if (!self.filter(self.buffer[offset])) break;
        }

        if (offset == self.buffer.len) {
            self.index = null;
        } else {
            self.index = offset;
        }
        
        return self.buffer[new_start..offset];
    }
};

/// For word spliting we'll assume any non-ascii character is in the same class
/// as Alpha character. Alternatively we could just assume Ascii alpha characters
fn alphaOrUnicode(c: u8) bool {
    return std.ascii.isAlpha(c) or !std.ascii.isASCII(c);
}

fn charFilter(string: []const u8) FilterIterator {
    return FilterIterator {
        .buffer = string,
        .index = 0,
        .filter = alphaOrUnicode,
    };
} 


fn firstWord(string: []const u8) ?[]const u8 {
    var filter = charFilter(string);
    return filter.next();
}

fn printFirstWord(string: []const u8) void {
    std.debug.print("Print First Word:\n", .{});
    var out: []const u8 = firstWord(string) orelse {
        std.debug.print("  Error: no first word\n", .{});
        return;
    };
    std.debug.print("{s}\n", .{out});
    return;
}



fn wordCounter(word_map: *std.StringHashMap(u32), string: []const u8) !usize {

    var filter = charFilter(string);
    
    var word = filter.next() orelse return 0;
    
    var count: u32 = 0;
    var max_word: u32 = 1;

    while (true) {
        if (!word_map.contains(word)) {
            try word_map.put(word, 1);
        } else {
            count = word_map.get(word).?;
            count += 1;
            try word_map.put(word, count);
            max_word = std.math.max(max_word, count);
        }
        word = filter.next() orelse break;
    } else {}
 
    return max_word;

}

fn printMostCommonWords(allocator: *Allocator, string: []const u8) !void {

    std.debug.print("Print Most Common Words\n", .{});

    var word_map = std.StringHashMap(u32).init(allocator);
    defer word_map.deinit();

    var max_words = try wordCounter(&word_map, string);
    if (max_words == 0) {
        std.debug.print("  Error: Did not find any words\n", .{});
        return;
    }
    
    var iter = word_map.iterator();
    std.debug.print(" Most Common Words:\n", .{});
    while (iter.next()) |kv| {
        if (kv.value == max_words) {
            std.debug.print("  {s} ({})\n", .{kv.key, kv.value});
        }
    }
    return;
}


fn longestLines(list: *std.ArrayList([]const u8), string: []const u8) usize {

    var longest: usize = 0;
    
    var slices = std.mem.tokenize(string, "?!.");
    var slice = slices.next() orelse {
        return longest;
    };


    // I don't like how we end up storing all the slices then iterating through
    // them later and print the maxs. Perhaps a better approach is to add to
    // arraylist, replacing if a new max is found. At then shrink the list
    // down to the actual size. (This requires keep track of the max len and 
    // number of those max
    while (true) {
        list.append(slice) catch unreachable;
        longest = std.math.max(longest, slice.len);
        slice = slices.next() orelse {
            break;
        };
    }
    return longest;

}

fn printLongestLines(allocator: *Allocator, string: []const u8) !void {
    
    std.debug.print("Print Longest Lines\n", .{});
    
    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit();
        
    var line_len = longestLines(&list, string);
    if (line_len == 0) {
        std.debug.print(" Nothing in {s}\n", .{string});
        return;
    }
   
    // meh see above
    for (list.items) |item| {
        if (item.len == line_len) {
            std.debug.print("{s}\n", .{item});
        }
    }
}


fn printCharacterGroups(string: []const u8) void {
    
    std.debug.print("Print Character Groups\n", .{});

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

fn printUnicodeGroups(string: []const u8) !void {
    
    std.debug.print("Print Character Groups\n", .{});

    var i: usize = 0;
    var last_cp: []const u8 = undefined;

    std.debug.print("Character Groups:\n", .{});

    var unicode_view = try std.unicode.Utf8View.init(string);
    var utf8 = unicode_view.iterator();

    while (utf8.nextCodepointSlice()) |cp| : (i+=1) {
        if ( i!=0 and !std.mem.eql(u8, last_cp,cp)) {
            std.debug.print(", ", .{});
        }
        std.debug.print("{s}", .{cp});
        last_cp = cp;
    }
    std.debug.print("\n", .{});
}

fn printSubString(string: []const u8, start: usize, end: usize) void {
    std.debug.print("Print Sub String:\n", .{});
    if ( start < end and end < string.len ) {
        std.debug.print("{s}\n", .{string[start..end]});
    } else {
        std.debug.print("Invalid range\n", .{});
    }
}

fn printSubStringUnicode(string: []const u8, start: usize, end: usize) !void {
    std.debug.print("Print Sub String:\n", .{});
    if ( !(start < end and end < string.len) ) {
        std.debug.print("Invalid range\n", .{});
        return;
    } 
   
    var i: usize = 0;
    var range = end-start;

    var unicode_view = try std.unicode.Utf8View.init(string);
    var utf8 = unicode_view.iterator();
    while (i<start) : (i+=1) {
        _ = utf8.nextCodepointSlice();
    }
    std.debug.print("{s}\n", .{utf8.peek(range)});
}

fn replaceStr(allocator: *Allocator, string: []const u8, needle: []const u8, replace: []const u8) ?[]u8 {
    
    var replacement_size = std.mem.replacementSize(u8, string, needle, replace);
    var replaced = allocator.alloc(u8, replacement_size) catch {
        return null;
    };
    _ = std.mem.replace(u8, string, needle, replace, replaced);

    return replaced;
}

fn printWithReplacement(allocator: *Allocator, string: []const u8, needle: []const u8, replace: []const u8) void {
   
    std.debug.print("Replace with Sub String:\n", .{});
    var str = replaceStr(allocator, string, needle, replace) orelse {
        std.debug.print("Failed to allocate string", .{});
        return;
    };
    defer allocator.free(str);
    
    std.debug.print("Replaced String:\n", .{});
    std.debug.print("{s}\n", .{str});

    return;
}


fn examples(string: []const u8) !void {

    
    // Get an allocator
    const allocator = std.heap.page_allocator;
    
    // Create a lower case string
    var lower_string = try std.ascii.allocLowerString(allocator, string);
    defer allocator.free(lower_string);
    
    std.debug.print("\n##################################################################\n\n", .{});
    std.debug.print("String:\n{s}\n", .{string});
    std.debug.print("\n------------------------------------------------------------------\n", .{});

    // First Word
    printFirstWord(string);
    std.debug.print("\n------------------------------------------------------------------\n", .{});

    // Most Common Words
    try printMostCommonWords(allocator, lower_string);
    std.debug.print("\n------------------------------------------------------------------\n", .{});
    
    // printCharacterGroups(string);
    try printUnicodeGroups(string);
    std.debug.print("\n------------------------------------------------------------------\n", .{});

    try printLongestLines(allocator, string);
    std.debug.print("\n------------------------------------------------------------------\n", .{});

    try printSubStringUnicode(string, 2, 5);
    std.debug.print("\n------------------------------------------------------------------\n", .{});
    
    printWithReplacement(allocator, string, "a", "A🍎");
    std.debug.print("\n------------------------------------------------------------------\n", .{});
}


pub fn main() anyerror!void {
   
    try examples("All your codebase are belong to us.");

    try examples(
        \\# String Shenanigans!
        \\
        \\Thanks to Jim for this idea!
        \\Get the first word in a string.
        \\Count the most common words in a string.
        \\Output the longest line in a string.
    );

    try examples("👀 🧠 unicode is a bit 💩💩!");
}


test "while how" {
    var i: usize = 0;

    // increments only happen on a continue.
    while (i<5) : (i+=1) {
        break;
    }
    std.testing.expect(i==0);
}

test "bad slice" {

    const str = "hello there";
    var a: u32 = 1;
    var b: u32 = a+4;

    std.testing.expectEqualStrings("ello", str[a..b]);

    // This will crash in unsafe modes
    // and will raise an index out of bounds in safe mode.
    // std.testing.expectEqualStrings("olle", str[b..a]);

}

test "filter test" {

    var filter = charFilter("7hello you there");

    std.testing.expect( std.mem.eql(u8, filter.next().?, "hello"));
    std.testing.expect( std.mem.eql(u8, filter.next().?, "you"));
    std.testing.expect( std.mem.eql(u8, filter.next().?, "there"));
    std.testing.expect( filter.next() == null );

    filter = charFilter("a");
    std.testing.expect( std.mem.eql(u8, filter.next().?, "a"));
    std.testing.expect( filter.next() == null );
    
    filter = charFilter("77");
    std.testing.expect( filter.next() == null );
    
    filter = charFilter("7aa7");
    std.testing.expect( std.mem.eql(u8, filter.next().?, "aa"));
    std.testing.expect( filter.next() == null );

}

test "unicode 1" {

    const str = "👀 🧠 unicode is a bit 💩💩!";
    std.debug.print("\n", .{});
    for (str) |i| {
        std.debug.print("{} ", .{i});
    }
    std.debug.print("\n", .{});
    for (str) |i| {
        std.debug.print("{x} ", .{i});
    }
    std.debug.print("\n", .{});

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
