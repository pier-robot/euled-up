const std = @import("std");

const lowest : i32 = 1;
const highest : i32 = 100;

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    return line;
}

fn gameLoop(reader: anytype, 
            writer: anytype, 
            picked_num: i32) !bool {

    var buffer: [100]u8 = undefined;
    var run_loop = true;
    
    while ( run_loop ) {

        writer.print("Your guess is: ", .{}) catch return false;
        
        const input = (try nextLine(reader, &buffer)).?;
        if ( std.ascii.eqlIgnoreCase(input,"q")) {
            writer.print("Later scumbag\n", .{}) catch return false;
            return false;
        }
    
        var input_val = std.fmt.parseInt(i32, input, 10) catch |err| {
            writer.print("Invalid value\n", .{}) catch return false;
            continue;
        };

        if ( input_val > picked_num ) {
            writer.print("Your pick is too large.\n", .{}) catch {};
        } else if ( input_val < picked_num ) {
            writer.print("Your pick is too small\n", .{}) catch return false;
        } else {
            writer.print("Winner winner, chicken dinner!\n", .{}) catch return false;
            return true;
        }

    }
   
    return true;
}

pub fn main() !void {
    const stdin = std.io.getStdIn();
    const stdout = std.io.getStdOut();

    stdout.writeAll(
        "Guess a number between 1 and 100 (inclusive) or 'q' to quit.\n",
    ) catch unreachable;

    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var rand = std.rand.DefaultPrng.init(seed);
    
    const picked_num : i32 = rand.random.intRangeAtMost(u8, lowest, highest);

    _ = gameLoop(stdin.reader(), stdout.writer(), picked_num) catch unreachable;
        
}

