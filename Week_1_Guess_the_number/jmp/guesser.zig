// Import the standard library
const std = @import("std");

// Define the range as constants
const lowest : i32 = 1;
const highest : i32 = 100;

// Let's return a type, error and a conditional! :D
fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    return line;
}

// public function main, returns nothing
pub fn main() void {

    // Here we get stdin and stdout from the std library
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    
    // Get a seed value, here we can explicitly state that a var is undefined
    var seed: u64 = undefined;

    std.os.getrandom(std.mem.asBytes(&seed)) catch |err| {
        stdout.print("Unable to seed random, defaulting to 0\n", .{}) catch unreachable;
        seed = 0;
    };
    
    var rand = std.rand.DefaultPrng.init(seed);
    const picked_num : i32 = rand.random.intRangeAtMost(u8, lowest, highest);
    var buffer: [100]u8 = undefined;
    
    // Start off by prompting the user
    // catch unreachable means this shouldn't error, in safe mode this will trigger a panic/crash
    // in unsafe mode the behavior is undefined
    stdout.print(
        "Guess a number between {} and {} (inclusive) or 'q' to quit.\n", 
        .{lowest, highest}) catch unreachable;

    while ( true ) {

        stdout.print("Your guess is: ", .{}) catch unreachable;
        
        // We fetch the input from stdin

        // what is this mess? It's easy! 
        var input = (nextLine(stdin, &buffer) catch {
            stdout.print("Error reading input, exiting\n", .{}) catch return;
            return;
            }).?;

        // Compare our input to "q" or "Q", if it is, quit
        if ( std.ascii.eqlIgnoreCase(input,"q")) {
            stdout.print("Later scumbag\n", .{}) catch return;
            return;
        }
   
        // Convert our ascii input to an int
        // Zig doesn't have exceptions instead a function can be set to
        // return either a val or an error set, it does this by making
        // a union type of the possible return value and the error set.

        // The following spilts the return/error set into the actual return
        // value and catching the error. If the catch |err| was not there
        // input_val would fail as you can store a i32,error set union as a
        // i32 type.
        var input_val : i32 = std.fmt.parseInt(i32, input, 10) catch {
            stdout.print("Invalid value\n", .{}) catch {};
            continue;
        };

        if ( input_val > highest or input_val < lowest ) {
            stdout.print("Pick out of bounds, choose a number between {} and {}.\n", 
            .{lowest, highest}) catch {};
        } else if ( input_val > picked_num ) {
            stdout.print("Your pick is too large.\n", .{}) catch {};
        } else if ( input_val < picked_num ) {
            stdout.print("Your pick is too small\n", .{}) catch {};
        } else {
            stdout.print("Winner winner, chicken dinner!\n", .{}) catch {};
            return;
        }
    }
    return;
}

