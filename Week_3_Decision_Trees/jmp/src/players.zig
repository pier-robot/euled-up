const std = @import("std");
const expect = std.testing.expect;

const board = @import("board.zig");

const Board = board.Board;
const Play = board.Play;

// Let's return a type, error and a conditional! :D
fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    return line;
}

pub const ATD = struct {
    play: Play,
    rand: std.rand.DefaultPrng,
    name: []const u8 = "ATD",

    pub fn init(play: Play) ATD {
        var seed: u64 = undefined;
        std.os.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Unable to seed random, defaulting to 0\n", .{});
            seed = 0;
        };
        return ATD{
            .play = play,
            .rand = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn seedRNG(self: *@This(), seed: u64) void {
        self.rand = std.rand.DefaultPrng.init(seed);
    }

    pub fn pickPos(self: *@This(), game_board: Board) u4 {
        var highest = game_board.numFreeSpaces();
        var rand_pick = self.rand.random.intRangeAtMost(u4, 0, highest - 1);
        var checked_space: u4 = 0;
        for (game_board.spaces) |space, current_space| {
            if (space != Play.empty) {
                continue;
            }
            if (checked_space == rand_pick) {
                return @intCast(u4, current_space);
            }
            checked_space += 1;
        }
        // TODO:
        // We shouldn't reach this point;
        //  raise error if we get here.
        std.debug.print("Should not have reached here\n", .{});
        return 8;
    }

    pub fn playBoard(self: *@This(), game_board: *Board) void {
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(self.play, pos);
    }
};

pub const Human = struct {
    play: Play,
    name: []const u8 = "Human",

    pub fn init(play: Play) Human {
        return Human{
            .play = play,
        };
    }
    
    fn print_help(self: @This(), game_board: Board) void {
        std.debug.print("789\n456\n123\n", .{});
        return;
    }

    pub fn pickPos(self: @This(), game_board: Board) u4 {
        const stdin = std.io.getStdIn().reader();
        var buffer: [100]u8 = undefined;

        while (true) {
            std.debug.print("Pick your position (1-9 or h)\n", .{});
            var input = (nextLine(stdin, &buffer) catch {
                std.debug.print("Error reading input, try again\n", .{});
                continue;
            }).?;
            if (std.ascii.eqlIgnoreCase(input, "h")) {
                self.print_help(game_board);
                continue;
            }
            var input_val: u4 = std.fmt.parseInt(u4, input, 10) catch {
                std.debug.print("Invalid value\n", .{});
                continue;
            };
            if (input_val < 0 and input_val > 9) {
                std.debug.print("Pick your position (1-9 or h)\n", .{});
                continue;
            }
            if (game_board.spaces[input_val - 1] != Play.empty) {
                std.debug.print("Occupied, pick another space.\n", .{});
                continue;
            }
            return input_val - 1;
        }
    }

    pub fn playBoard(self: @This(), game_board: *Board) void {
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(self.play, pos);
    }
};

test "Players: ATD empty board pick" {
    var b = Board.init();
    var atd = ATD.init(Play.o);
    atd.seedRNG(42);

    var pos = atd.pickPos(b);

    var rand = std.rand.DefaultPrng.init(42);
    var rand_pick = rand.random.intRangeAtMost(u4, 0, 8);

    expect(pos == rand_pick);
}

test "Players: ATD pick till full" {
    var b = Board.init();
    var atd = ATD.init(Play.o);
    atd.seedRNG(42);

    var i: u4 = 0;
    while (i < 9) {
        atd.playBoard(&b);
        i += 1;
    }
    expect(b.numFreeSpaces() == 0);
}

test "Players: Two ATD pick till full" {
    var b = Board.init();
    var atd_a = ATD.init(Play.o);
    var atd_b = ATD.init(Play.x);
    atd_a.seedRNG(42);
    atd_b.seedRNG(43);

    for (b.spaces) |_, turn| {
        std.debug.print("Turn: {}\n", .{turn});
        if (@mod(turn, 2) == 0) {
            atd_b.playBoard(&b);
        } else {
            atd_a.playBoard(&b);
        }
        b.printBoard();
    }

    expect(b.numFreeSpaces() == 0);
}
