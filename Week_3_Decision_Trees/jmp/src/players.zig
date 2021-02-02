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

pub const Player = struct {
    play: Play,
    name: []const u8,
    playBoardFn: fn (player: *Player, game_board: *Board) void,

    pub fn playBoard(self: *Player, game_board: *Board) void {
        self.playBoardFn(self, game_board);
    }
};

const off_board = 9;

/// ATD Player definition
pub const ATD = struct {
    player: Player,
    rand: std.rand.DefaultPrng,

    pub fn init(play: Play, name: []const u8) ATD {
        var seed: u64 = undefined;
        std.os.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Unable to seed random, defaulting to 0\n", .{});
            seed = 0;
        };

        return ATD{
            .player = Player{
                .play = play,
                .name = name,
                .playBoardFn = playBoardCallback,
            },
            .rand = std.rand.DefaultPrng.init(seed),
        };
    }

    pub fn reSeedRNG(self: *@This(), seed: u64) void {
        self.rand.seed(seed);
    }

    fn pickPos(self: *@This(), game_board: Board) u4 {
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

    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(ATD, "player", player);
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(player.play, pos);
    }
};

/// Perfect Player definition
pub const Perfect = struct {
    player: Player,

    pub fn init(play: Play, name: []const u8) Perfect {
        return Perfect{
            .player = Player{
                .play = play,
                .name = name,
                .playBoardFn = playBoardCallback,
            },
        };
    }

    /// If the player has two in a row
    fn check_for_wins(self: @This(), game_board: Board, play: Play) u4 {
        for (board.incidence_structure) |line| {
            var x_count: u4 = 0;
            var o_count: u4 = 0;
            var empty_count: u4 = 0;
            var last_position: u4 = off_board;
            for (line) |position| {
                switch (game_board.positions[position]) {
                    Play.x => {
                        x_count += 1;
                    },
                    Play.o => {
                        o_count += 1;
                    },
                    Play.empty => {
                        empty_count += 1;
                        last_position = position;
                    },
                }
            }
            if (play == Play.x and x_count == 2 and empty_count == 1) {
                return last_position;
            }
            if (play == Play.o and o_count == 2 and empty_count == 1) {
                return last_position;
            }
        }
        return off_board;
    }

    fn check_opposite_corners(self: @This(), game_board: Board) u4 {
        var other_player: Play = if (self.player.play == Play.x) Play.o else Play.x;
        for (board.corners) |corner, i| {
            // board.corners is ordered in such a way we can just invert the lookup
            // to find the opposite corner.
            var opposite_corner = board.corners.len - i;
            if (game_board.positions[corner] == other_player and
                game_board.positions[opposite_corner] == Play.empty)
            {
                return @intCast(u4, opposite_corner);
            }
        }
        return off_board;
    }

    fn check_empty_positions(self: @This(), game_board: Board, positions: [4]u4) u4 {
        // TODO randomize search so it's not always the same corner?
        for (positions) |pos| {
            if (game_board.positions[pos] == Play.empty) {
                return pos;
            }
        }
        return off_board;
    }

    fn find_forks(self: @This(), game_board: Board, player: Play) u4 {
        // Find out what shape the other player has
        var other_player: Play = if (self.player.play == Play.x) Play.o else Play.x;
        // Now we loop through all possible game lines
        line_loop: for (board.incidence_structure) |line, line_num| {
            var empty_count: u4 = 0;
            var found_player: bool = false;
            var player_position: u4 = off_board;
            // We are going to store up to 3 empty positions in a line
            // though we will only care about the cases where we find 2
            var empty_positions = [_]u4{off_board} ** 3;
            for (line) |position| {
                var pos_play = game_board.positions[position];
                // If the other player is in this line, then we can bail from this line completely
                if (pos_play == other_player) continue :line_loop;
                // Otherwise we'll keep track of the empty positions
                if (pos_play == Play.empty) {
                    empty_positions[empty_count] = position;
                    empty_count += 1;
                    // And verify we found the player in one of the positions
                } else {
                    found_player = true;
                    player_position = position;
                }
            }

            // If we didn't have two empty spaces or didn't find the player then we
            // can't use this line
            if (empty_count != 2 or !found_player) continue :line_loop;

            // If we are still in the loop that means we have a candidate line,
            // now we'll check both empty positions for possible intersections with other
            // candidate lines.
            for (empty_positions[0..2]) |the_empty_pos| {
                // Once again loop through the lines
                second_line_loop: for (board.incidence_structure) |line2, line_num2| {
                    var empty_count2: u4 = 0;
                    // We can skip the line we are already evaluating in the main loop
                    if (line_num == line_num2) continue;
                    var intersection: bool = false;
                    // Check each position in other lines looking for an intersection
                    // with our candidate line above as well as verifying this line
                    // meets the same requirements above (2 empties, no other player
                    // 1 player that isn't the same position we are already evaluating
                    for (line2) |position2| {
                        var pos_play2 = game_board.positions[position2];
                        if (pos_play2 == other_player) continue :second_line_loop;
                        if (position2 == player_position) continue :second_line_loop;
                        if (position2 == the_empty_pos) intersection = true;
                        if (pos_play2 == Play.empty) empty_count2 += 1;
                    }
                    if (intersection and empty_count2 == 2) return the_empty_pos;
                }
            }
        }
        return off_board;
    }

    fn pickPos(self: @This(), game_board: Board) u4 {
        var other_play: Play = if (self.player.play == Play.x) Play.o else Play.x;

        var pos: u4 = undefined;

        // 1. Win
        pos = self.check_for_wins(game_board, self.player.play);
        if (pos < off_board) return pos;

        // 2. Block
        pos = self.check_for_wins(game_board, other_play);
        if (pos < off_board) return pos;

        // 3. Fork
        pos = self.find_forks(game_board, self.player.play);
        if (pos < off_board) return pos;

        // 4. Blocking an opponent's fork
        //  4a: If there is only one possible fork for the opponent, block it.
        //  4b: The player should block all forks in any way that simultaneously allows them to create two in a row.
        //  4c  The player should create a two in a row that doesn't result in them creating an opponent fork.

        // For perfect play, step 5 and 7 can be swapped
        // 5. Center
        if (game_board.positions[board.middle] == Play.empty) return board.middle;

        // 6. Opposite corner
        pos = self.check_opposite_corners(game_board);
        if (pos < off_board) return pos;

        // 7. Empty corner
        pos = self.check_empty_positions(game_board, board.corners);
        if (pos < off_board) return pos;

        // 8. Empty side
        pos = self.check_empty_positions(game_board, board.mid_sides);
        if (pos < off_board) return pos;

        // TODO shouldn't reach this point
        return off_board;
    }

    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(Perfect, "player", player);
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(player.play, pos);
    }
};

/// Human Player definition
pub const Human = struct {
    player: Player,

    pub fn init(play: Play, name: []const u8) Human {
        return Human{
            .player = Player{
                .play = play,
                .name = name,
                .playBoardFn = playBoardCallback,
            },
        };
    }

    fn print_help(self: @This(), game_board: Board) void {
        std.debug.print("Board positions are:\n", .{});
        std.debug.print("7┃8┃9\n" ++
            "━╋━╋━\n" ++
            "4┃5┃6\n" ++
            "━╋━╋━\n" ++
            "1┃2┃3\n", .{});
        return;
    }

    fn pickPos(self: @This(), game_board: Board) u4 {
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

    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(Human, "player", player);
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(player.play, pos);
    }
};

test "Players: ATD empty board pick" {
    var b = Board.init();
    var atd = ATD.init(Play.o, "atd");
    atd.reSeedRNG(42);

    var pos = atd.pickPos(b);

    var rand = std.rand.DefaultPrng.init(42);
    var rand_pick = rand.random.intRangeAtMost(u4, 0, 8);

    expect(pos == rand_pick);
}

test "Players: ATD pick till full" {
    var b = Board.init();
    var atd = ATD.init(Play.o, "atd");
    atd.reSeedRNG(42);

    var i: u4 = 0;
    while (i < 9) {
        atd.player.playBoard(&b);
        i += 1;
    }
    expect(b.numFreePositions() == 0);
}

test "Players: Two ATD pick till full" {
    var b = Board.init();
    var atd_a = ATD.init(Play.o, "atd a");
    var atd_b = ATD.init(Play.x, "atd b");
    atd_a.reSeedRNG(42);
    atd_b.reSeedRNG(43);
    var player1 = &atd_a.player;
    var player2 = &atd_b.player;

    for (b.positions) |_, turn| {
        if (@mod(turn, 2) == 0) {
            player1.playBoard(&b);
        } else {
            player2.playBoard(&b);
        }
    }

    expect(b.numFreePositions() == 0);
}
