const std = @import("std");
const expect = std.testing.expect;

/// Possible play states on the board.
pub const Play = enum {
    empty,
    x,
    o,
};

/// aka "win lines"
pub const incidence_structure = [_][3]u4{
    [_]u4{ 0, 1, 2 },
    [_]u4{ 3, 4, 5 },
    [_]u4{ 6, 7, 8 },

    [_]u4{ 0, 3, 6 },
    [_]u4{ 1, 4, 7 },
    [_]u4{ 2, 5, 8 },

    [_]u4{ 0, 4, 8 },
    [_]u4{ 2, 4, 6 },
};
pub const corners = [_]u4{ 0, 2, 6, 8 };
pub const mid_sides = [_]u4{ 1, 3, 5, 7 };
pub const middle = 4;

/// Helper function to convert enum values to characters for printing.
fn play_to_char(play: Play) u8 {
    return switch (play) {
        .empty => ' ',
        .x => 'x',
        .o => 'o',
    };
}

/// Helper function for printing the board with fancy pants characters`
fn boardPrinter(positions: anytype) void {
    std.debug.print("{c}┃{c}┃{c}\n", .{
        play_to_char(positions[6]),
        play_to_char(positions[7]),
        play_to_char(positions[8]),
    });
    std.debug.print("━╋━╋━\n", .{});
    std.debug.print("{c}┃{c}┃{c}\n", .{
        play_to_char(positions[3]),
        play_to_char(positions[4]),
        play_to_char(positions[5]),
    });
    std.debug.print("━╋━╋━\n", .{});
    std.debug.print("{c}┃{c}┃{c}\n", .{
        play_to_char(positions[0]),
        play_to_char(positions[1]),
        play_to_char(positions[2]),
    });
    return;
}

/// Represents a play on the board.
const BoardPlay = struct {
    position: u4,
    play: Play,
};

pub const Board = struct {
    /// Array of positions on the board that record the play states.
    positions: [9]Play,
    /// Record the current turn number. This starts with 1, ie the 1st turn.
    turn_num: u4,
    /// An array of BoardPlays (positions and plays). This provides a history of the turns
    /// in a game.
    plays: [9]BoardPlay,

    pub fn init() Board {
        return Board{
            .positions = [_]Play{Play.empty} ** 9,
            .turn_num = 1,
            // initialize to empty plays and out of bounds positions.
            .plays = [_]BoardPlay{BoardPlay{ .position = 9, .play = Play.empty }} ** 9,
        };
    }

    /// Number of free positions on the board.
    pub fn numFreePositions(self: Board) u4 {
        // We can derive the free positions by using the turns taken
        return 9 - (self.turn_num - 1);
        // Alternatively we can evaluate the board directly which is slower.
        // var count: u4 = 0;
        // for (self.positions) |position| {
        //     if (position == Play.empty) {
        //         count += 1;
        //     }
        // }
        // return count;
    }

    /// Reset the board back ot the starting state.
    pub fn reset(self: *@This()) void {
        for (self.positions) |*position| {
            position.* = Play.empty;
        }
        for (self.plays) |*play| {
            play.position = 9;
            play.play = Play.empty;
        }
        self.turn_num = 1;
    }

    /// Play a position on the board, and record it in the list of plays.
    pub fn playPosition(self: *@This(), play: Play, pos: u4) void {
        // TODO add errors for
        // pos > 8
        // positions[pos] != Play.empty
        self.positions[pos] = play;
        self.plays[self.turn_num - 1] = BoardPlay{ .position = pos, .play = play };
        self.turn_num += 1;
    }

    /// Print all the plays up to the current turn, optionally clear console before printing.
    pub fn printPlays(self: @This(), clear: bool) void {
        if (clear) std.debug.print("\x1B[2J", .{});
        var count: u4 = 0;
        var positions = [_]Play{Play.empty} ** 9;
        while (count < self.turn_num) {
            positions[self.plays[count].position] = self.plays[count].play;
            boardPrinter(positions);
            std.debug.print("-----\n", .{});
            count += 1;
        }
        return;
    }

    /// Print the current board state, optionally clear console before printing.
    pub fn printBoard(self: @This(), clear: bool) void {
        if (clear) std.debug.print("\x1B[2J", .{});
        boardPrinter(self.positions);
    }

    /// Check to see if a win state has occured.
    pub fn winnerIs(self: @This()) Play {
        // Are all three positions in a line the same and not empty?
        for (incidence_structure) |line| {
            if (self.positions[line[0]] == self.positions[line[1]] and
                self.positions[line[0]] == self.positions[line[2]] and
                self.positions[line[0]] != Play.empty)
            {
                return self.positions[line[0]];
            }
        }
        return Play.empty;
    }
};

test "Board: size" {
    var b = Board.init();
    expect(b.positions.len == 9);
}

test "Board: instanced zerod" {
    var b = Board.init();
    expect(b.numFreePositions() == 9);
}

test "Board: plays" {
    var b = Board.init();
    b.playPosition(Play.x, 4);
    b.playPosition(Play.o, 3);
    expect(b.numFreePositions() == 7);
}

test "Board: winner none" {
    var b = Board.init();
    expect(b.winnerIs() == Play.empty);
}

test "Board: winner X" {
    var b = Board.init();
    b.playPosition(Play.x, 0);
    b.playPosition(Play.x, 3);
    b.playPosition(Play.x, 6);
    expect(b.winnerIs() == Play.x);
}
