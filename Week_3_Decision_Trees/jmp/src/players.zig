//! Players module provides functionality for different player types.
//! This includes a:
//! Human - requires input from user (you)
//! ATD - randomly picks a position
//! PipeTD - uses minimax algorithm
//! Supe - always plays a perfect game using https://en.wikipedia.org/wiki/Tic-tac-toe#Strategy


const std = @import("std");
const expect = std.testing.expect;

const board = @import("board.zig");
const utils = @import("utils.zig");

const Board = board.Board;
const Play = board.Play;

/// ATD Player definition
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

    pub fn reSeedRNG(self: *@This(), seed: u64) void {
        self.rand.seed(seed);
    }

    pub fn pickPos(self: *@This(), game_board: Board) u4 {
        var highest = game_board.numFreePositions();
        var rand_pick = self.rand.random.intRangeAtMost(u4, 0, highest - 1);
        var checked_position: u4 = 0;
        for (game_board.positions) |position, current_position| {
            if (position != Play.empty) {
                continue;
            }
            if (checked_position == rand_pick) {
                return @intCast(u4, current_position);
            }
            checked_position += 1;
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

/// Human Player definition
pub const Human = struct {
    play: Play,
    name: []const u8 = "Human",

    pub fn init(play: Play) Human {
        return Human{
            .play = play,
        };
    }
    
    fn print_help(self: @This(), game_board: Board) void {
        std.debug.print("Board positions are:\n", .{});
        std.debug.print(
            "7┃8┃9\n" ++
            "━╋━╋━\n" ++
            "4┃5┃6\n" ++
            "━╋━╋━\n" ++
            "1┃2┃3\n", .{});
        return;
    }

    pub fn pickPos(self: @This(), game_board: Board) u4 {
        while (true) {
            std.debug.print("Pick your position (1-9 or h)\n", .{});
            var input = utils.readInput();
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
            if (game_board.positions[input_val - 1] != Play.empty) {
                std.debug.print("Occupied, pick another position.\n", .{});
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
    atd.reSeedRNG(42);

    var pos = atd.pickPos(b);

    var rand = std.rand.DefaultPrng.init(42);
    var rand_pick = rand.random.intRangeAtMost(u4, 0, 8);

    expect(pos == rand_pick);
}

test "Players: ATD pick till full" {
    var b = Board.init();
    var atd = ATD.init(Play.o);
    atd.reSeedRNG(42);

    var i: u4 = 0;
    while (i < 9) {
        atd.playBoard(&b);
        i += 1;
    }
    expect(b.numFreePositions() == 0);
}

test "Players: Two ATD pick till full" {
    var b = Board.init();
    var atd_a = ATD.init(Play.o);
    var atd_b = ATD.init(Play.x);
    atd_a.reSeedRNG(42);
    atd_b.reSeedRNG(43);

    for (b.positions) |_, turn| {
        if (@mod(turn, 2) == 0) {
            atd_b.playBoard(&b);
        } else {
            atd_a.playBoard(&b);
        }
    }

    expect(b.numFreePositions() == 0);
}
