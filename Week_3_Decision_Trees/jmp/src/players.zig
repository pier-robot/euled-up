//! Players module provides functionality for different player types.
//! This includes a:
//! Human - requires input from user (you)
//! ATD - randomly picks a position
//! PipeTD - uses minimax algorithm
//! Supe - always plays a perfect game using https://en.wikipedia.org/wiki/Tic-tac-toe#Strategy

const std = @import("std");

const board = @import("board.zig");
const utils = @import("utils.zig");

const Board = board.Board;
const Play = board.Play;

/// Define a generic Player that will interact with the board.
/// This provide the interface through which the various types of players provide an
/// implementation for the playBoardFn.
pub const Player = struct {
    play: Play,
    name: []const u8,
    playBoardFn: fn (player: *Player, game_board: *Board) void,

    pub fn playBoard(self: *Player, game_board: *Board) void {
        self.playBoardFn(self, game_board);
    }
};

// The board holds values between 0 through 8, we use the off_board value to check if
// we are out of bounds.
const off_board = 9;

const pdebug = false;

/// ATD Player definition
pub const ATD = struct {
    player: Player,
    rand: std.rand.DefaultPrng,

    /// Initialize an ATD Player, and select a random seed
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

    /// Reseed the RNG for the ATD
    pub fn reSeedRNG(self: *@This(), seed: u64) void {
        self.rand.seed(seed);
    }

    /// Pick a position on the board given it's current state.
    fn pickPos(self: *@This(), game_board: Board) u4 {
        // Find the number of empty positions and pick a random integer within
        // that range.
        var highest = game_board.numFreePositions();
        var rand_pick = self.rand.random.intRangeAtMost(u4, 0, highest - 1);
        var empty_position_num: u4 = 0;
        for (game_board.positions) |position, current_position| {
            // Skip occupied positions
            if (position != Play.empty) {
                continue;
            }
            // And skip empty positions until we have hit our random pick
            if (empty_position_num == rand_pick) {
                return @intCast(u4, current_position);
            }
            empty_position_num += 1;
        }
        return off_board;
    }

    /// Callback function that will be attached to the generic Player struct
    fn playBoardCallback(player: *Player, game_board: *Board) void {
        // Since this function will be called from within the Player struct we need
        // to derive "self", we do this by looking up the parent pointer of a field
        // of an instantiated struct.
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

    /// Check for possible win positions.
    /// Implements #1 and #2 of the perfect play strategy
    fn checkForWins(self: @This(), game_board: Board, play: Play) u4 {
        // loop through the various possible winning lines on the board and tally what state the
        // positions are in.
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
            // now that we have our stats, we can determine if this line has two in a row
            // and if so, who owns those two positions and what the empty position is.
            if (play == Play.x and x_count == 2 and empty_count == 1) {
                return last_position;
            }
            if (play == Play.o and o_count == 2 and empty_count == 1) {
                return last_position;
            }
        }
        return off_board;
    }

    /// Check for the opponent in each corner and return the opposite corner.
    /// Implements #6 of the perfect play strategy
    fn checkOppositeCorners(self: @This(), game_board: Board) u4 {
        var opponent: Play = if (self.player.play == Play.x) Play.o else Play.x;
        for (board.corners) |corner, i| {
            // board.corners is ordered in such a way we can just invert the lookup
            // to find the opposite corner.
            var opposite_corner = board.corners.len - i;
            if (game_board.positions[corner] == opponent and
                game_board.positions[opposite_corner] == Play.empty)
            {
                return @intCast(u4, opposite_corner);
            }
        }
        return off_board;
    }

    /// Check for empty positions on the board, this intended to evaluate the 4 middle
    /// side positions or the four corners.
    /// Implements #7 and #8 of the perfect play strategy
    fn checkEmptyPositions(self: @This(), game_board: Board, positions: [4]u4) u4 {
        // TODO randomize search so it's not always the same corner?
        for (positions) |pos| {
            if (game_board.positions[pos] == Play.empty) {
                return pos;
            }
        }
        return off_board;
    }

    /// Find possible fork positions on the board. This returns up to 4 possible positions
    /// where a fork can be created. Four possible forks is the maximum number of forks that
    /// can exist during play. This was determined after simulating millions of games as opposed
    /// to a formula.
    /// There is a lot of looping in this function but the two primary nested loops are to first
    /// loop through all the possible win lines. If a candidate line is found then all the lines
    /// are checked again with respect to candidate line looking for a possible fork senario.
    /// If one is found then it is recorded and the checks continue.
    /// Given certain conditions, like finding the opposing player in a line we can exit out of a
    /// loop earlier. This adds some extra lines of code but skips needless evaluations.
    /// This provides the information needed to implement #3 and #4 of the perfect play strategy
    fn findForks(self: @This(), game_board: Board, player: Play) [4]u4 {
        var forks = [_]u4{off_board} ** 4;
        var fork_count: u3 = 0;

        // Find out what shape the other player has
        var opponent: Play = if (player == Play.x) Play.o else Play.x;

        // Now we loop through all possible game lines
        line_loop: for (board.incidence_structure) |line, line_num| {
            if (pdebug) std.debug.print("line_num: {}\n", .{line_num});
            var empty_count: u4 = 0;
            var found_player: bool = false;
            var player_position: u4 = off_board;
            // We are going to store up to 3 empty positions in a line
            // though we will only care about the cases where we find 2
            var empty_positions = [_]u4{off_board} ** 2;

            for (line) |position| {
                var pos_play = game_board.positions[position];
                // If the other player is blocking this line, then we can bail from this line completely
                if (pos_play == opponent) continue :line_loop;
                // Otherwise we'll keep track of the empty positions
                if (pos_play == Play.empty) {
                    // If we've already found two empty positions a third doesn't help so jump out
                    if (empty_count > 1) continue :line_loop;
                    empty_positions[empty_count] = position;
                    empty_count += 1;
                } else {
                    // And verify we found the player in one of the positions
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
            empty_pos_loop: for (empty_positions) |the_empty_pos| {
                // We can skip (and avoid readding a fork) if we've aleady flagged it.
                for (forks) |fork| if (fork == the_empty_pos) continue :empty_pos_loop;
                // Once again loop through the lines
                second_line_loop: for (board.incidence_structure) |line2, line_num2| {
                    if (pdebug) std.debug.print("  line_num2 ({}): {}\n", .{ the_empty_pos, line_num2 });
                    var empty_count2: u4 = 0;
                    // We can skip the line we are already evaluating in the main loop
                    if (line_num == line_num2) continue;
                    var intersection: bool = false;
                    // Check each position in other lines looking for an intersection
                    // with our candidate line above as well as verifying this line
                    // meets the same requirements above (2 empties, no opponent blocking
                    // and we aren't evaluating a line that where candidate player position
                    // is in this line as well. ie) position 0 shows up in 3 lines so we can
                    // skip those.
                    for (line2) |position2| {
                        var pos_play2 = game_board.positions[position2];

                        if (pos_play2 == opponent) continue :second_line_loop;
                        if (position2 == player_position) continue :second_line_loop;
                        if (position2 == the_empty_pos) intersection = true;
                        if (pos_play2 == Play.empty) empty_count2 += 1;
                    }
                    if (intersection and empty_count2 == 2) {
                        if (pdebug) std.debug.print("  adding {} fork_count: {} {}\n", .{ the_empty_pos, fork_count, opponent });
                        forks[fork_count] = the_empty_pos;
                        fork_count += 1;
                    }
                }
            }
        }
        return forks;
    }

    /// Given possible fork positions this function determines which should be blocked.
    /// This provides a block position without forcing the opposing player into a fork.
    /// This implements the secondary conditions of #4 in the perfect play strategy.
    fn blockForks(self: @This(), game_board: Board, forks: [4]u4) u4 {
        var opponent: Play = if (self.player.play == Play.x) Play.o else Play.x;

        // Loop through all the possible win lines and gather metrics of each.
        // (Perhaps a better implementation would have been to combine this with the
        // findForks() method instead of having to rescan all the lines, but separating
        // out the logic helps keep the logic a bit more digestible.
        line_loop: for (board.incidence_structure) |line| {
            var num_player: u2 = 0;
            var num_empty: u2 = 0;
            // We are going to stash up to two potential blocks in this row. We know
            // there can't be 3 possible blocks in a row as there would need to be
            // at least one occupied spot to be a candidate.
            var blocks = [_]u4{off_board} ** 2;
            var num_blocks: u2 = 0;
            var has_block = false;
            for (line) |position| {
                if (game_board.positions[position] == opponent) continue :line_loop;
                if (game_board.positions[position] == self.player.play) {
                    num_player += 1;
                } else {
                    num_empty += 1;
                    if (forks[0] == position or
                        forks[1] == position or
                        forks[2] == position or
                        forks[3] == position)
                    {
                        blocks[num_blocks] = position;
                        num_blocks += 1;
                    }
                }
            }
            // continue to the next line if this one doesn't match the requirements
            if (num_player != 1 or num_empty != 2 or num_blocks == 0) continue;
            if (num_blocks == 1) {
                return blocks[0];
            }
        }
        return off_board;
    }

    /// Position picker for the perfect player
    fn pickPos(self: @This(), game_board: Board) u4 {
        var opponent: Play = if (self.player.play == Play.x) Play.o else Play.x;

        var pos: u4 = undefined;

        // 1. Win, only valid after turn 4 xoxo
        if (game_board.turn_num > 4) {
            if (pdebug) std.debug.print("1.\n", .{});
            pos = self.checkForWins(game_board, self.player.play);
            if (pos < off_board) return pos;
        }

        // 2. Block, only valid after turn 3 xox
        if (game_board.turn_num > 3) {
            if (pdebug) std.debug.print("2.\n", .{});
            pos = self.checkForWins(game_board, opponent);
            if (pos < off_board) return pos;
        }

        // 3. Fork, only valid after turn 4 xoxo
        if (game_board.turn_num > 4) {
            if (pdebug) std.debug.print("3.\n", .{});
            pos = self.findForks(game_board, self.player.play)[0];
            if (pos < off_board) return pos;
        }

        // 4. Blocking an opponent's fork, only valid after turn 3 xox
        if (game_board.turn_num > 3) {
            var forks = self.findForks(game_board, opponent);
            if (forks[0] != off_board) {
                if (pdebug) std.debug.print("4.\n", .{});
                //  4a: If there is only one possible fork for the opponent, block it.
                if (forks[1] == off_board) return forks[0];
                //  4b: The player should block all forks in any way that simultaneously allows them to create two in a row.
                //      The player should create a two in a row that doesn't result in them creating an opponent fork.
                pos = self.blockForks(game_board, forks);
                if (pos < off_board) return pos;
            }
        }

        // For perfect play, step 5 and 7 can be swapped

        // 5. Center
        if (pdebug) std.debug.print("5.\n", .{});
        if (game_board.positions[board.middle] == Play.empty) return board.middle;

        // 6. Opposite corner, only valid after turn 1
        if (game_board.turn_num > 1) {
            if (pdebug) std.debug.print("6.\n", .{});
            pos = self.checkOppositeCorners(game_board);
            if (pos < off_board) return pos;
        }

        // 7. Empty corner
        if (pdebug) std.debug.print("7.\n", .{});
        pos = self.checkEmptyPositions(game_board, board.corners);
        if (pos < off_board) return pos;

        // 8. Empty side
        if (pdebug) std.debug.print("8.\n", .{});
        pos = self.checkEmptyPositions(game_board, board.mid_sides);
        if (pos < off_board) return pos;

        // Shouldn't reach this point
        return off_board;
    }

    /// Implement callback function for Player struct
    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(Perfect, "player", player);
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(player.play, pos);
    }
};

/// Minimax Player definition
pub const Minimax = struct {
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

    // TODO we could improve this by having the positions implementation
    // as a field on a Board struct, that way we can separate the overall
    // board functionality from the more compact position info.

    fn winningPlayer(positions: [9]Play) Play {
        // Are all three positions in a line the same and not empty?
        for (board.incidence_structure) |line| {
            if (positions[line[0]] == positions[line[1]] and
                positions[line[0]] == positions[line[2]] and
                positions[line[0]] != Play.empty)
            {
                return positions[line[0]];
            }
        }
        return Play.empty;
    }

    fn numFreeSpots(positions: [9]Play) u4 {
        var free_spots: u4 = 0;
        for (positions) |position| {
            if (position == Play.empty) free_spots += 1;
        }
        return free_spots;
    }

    const PositionValue = struct {
        position: u4,
        value: i8,
    };

    fn minimax(self: @This(), positions: [9]Play, player: Play, depth: i8) PositionValue {

        var opponent: Play = if (self.player.play == Play.x) Play.o else Play.x;
        var other_player = if (player == Play.x) Play.o else Play.x; 

        var is_winner = winningPlayer(positions);
        if (is_winner == self.player.play) {
            return PositionValue {
                .position = off_board,
                .value = 10-depth,
            };
        }
        if (is_winner == opponent) {
            return PositionValue {
                .position = off_board,
                .value = -10+depth,
            };
        }
        if (numFreeSpots(positions) == 0) {
            return PositionValue {
                .position = off_board,
                .value = 0,
            };
        }
        
        var max_value: i8 = -100;
        var min_value: i8 = 100;
        var ranked_pos: u4 = off_board;

        for (positions) |play,position| {
            if (play != Play.empty) continue;
            var new_positions = positions;
            new_positions[position] = player;
            var result = self.minimax(new_positions, other_player, depth+1).value; 

            if (self.player.play == player and result > max_value) {
                ranked_pos = @intCast(u4, position);
                max_value = result;
            } else if (self.player.play != player and result < min_value) {
                ranked_pos = @intCast(u4, position);
                min_value = result;
            }
        }

        if (self.player.play == player) return PositionValue {
            .position = ranked_pos,
            .value = max_value
        };
        return PositionValue {
            .position = ranked_pos,
            .value = min_value,
        };
    }
   
    fn pickPos(self: @This(), game_board: Board) u4 {
        return self.minimax(game_board.positions, self.player.play, 0).position;
    }

    /// Implement callback function for Player struct
    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(Minimax, "player", player);
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

    /// If the user requests help print the board positions.
    /// Number pad is your friend.
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

    /// Implement callback function for Player struct
    fn playBoardCallback(player: *Player, game_board: *Board) void {
        const self = @fieldParentPtr(Human, "player", player);
        var pos = self.pickPos(game_board.*);
        game_board.playPosition(player.play, pos);
    }
};

const expect = std.testing.expect;

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

test "Players: Perfect trap 1" {
    var b = Board.init();
    b.playPosition(Play.x, 5);
    b.playPosition(Play.o, 4);
    b.playPosition(Play.x, 7);
    var perfect = Perfect.init(Play.o, "perfect");
    var forks = perfect.findForks(b, Play.x);
    var pos = perfect.pickPos(b);
    expect(pos == 8);
}

test "Players: Perfect trap 2" {
    var b = Board.init();
    b.playPosition(Play.x, 4);
    b.playPosition(Play.o, 0);
    b.playPosition(Play.x, 8);
    var perfect = Perfect.init(Play.o, "perfect");
    var forks = perfect.findForks(b, Play.x);
    expect(std.mem.eql(u4, &forks, &[_]u4{ 5, 6, 7, 2 }));
    var pos = perfect.pickPos(b);
    expect(pos == 2 or pos == 7);
}
