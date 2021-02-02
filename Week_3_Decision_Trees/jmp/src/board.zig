const std = @import("std");
const expect = std.testing.expect;

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

pub const Board = struct {
    positions: [9]Play,

    pub fn init() Board {
        return Board{
            .positions = [_]Play{Play.empty} ** 9,
        };
    }

    pub fn numFreePositions(self: Board) u4 {
        var count: u4 = 0;
        for (self.positions) |position| {
            if (position == Play.empty) {
                count += 1;
            }
        }
        return count;
    }

    pub fn reset(self: *@This()) void {
        for (self.positions) |*position| {
            position.* = Play.empty;
        }
    }

    pub fn playPosition(self: *@This(), play: Play, pos: u4) void {
        // TODO add errors for
        // pos > 8
        // positions[pos] != Play.empty
        self.positions[pos] = play;
    }

    fn play_to_char(play: Play) u8 {
        return switch (play) {
            .empty => ' ',
            .x => 'x',
            .o => 'o',
        };
    }

    pub fn printBoard(self: @This(), clear: bool) void {
        if (clear) std.debug.print("\x1B[2J", .{});
        std.debug.print("{c}┃{c}┃{c}\n", .{
            play_to_char(self.positions[6]),
            play_to_char(self.positions[7]),
            play_to_char(self.positions[8]),
        });
        std.debug.print("━╋━╋━\n", .{});
        std.debug.print("{c}┃{c}┃{c}\n", .{
            play_to_char(self.positions[3]),
            play_to_char(self.positions[4]),
            play_to_char(self.positions[5]),
        });
        std.debug.print("━╋━╋━\n", .{});
        std.debug.print("{c}┃{c}┃{c}\n", .{
            play_to_char(self.positions[0]),
            play_to_char(self.positions[1]),
            play_to_char(self.positions[2]),
        });
    }

    pub fn winnerIs(self: @This()) Play {
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
