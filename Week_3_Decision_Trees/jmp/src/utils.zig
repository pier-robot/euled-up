const std = @import("std");

/// Parses a line, used for reading in stdin
fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    return line;
}

/// Read input from stdin till a new line
pub fn readInput() []const u8 {
    const stdin = std.io.getStdIn().reader();
    var buffer: [100]u8 = undefined;

    while (true) {
        var input = (nextLine(stdin, &buffer) catch {
            std.debug.print("Error reading input, try again\n", .{});
            continue;
        }).?;
        return input;
    }

    return "";
}
