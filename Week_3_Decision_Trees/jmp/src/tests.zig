const std = @import("std");
const expect = std.testing.expect;

usingnamespace @import("board.zig");
usingnamespace @import("players.zig");

test "General: basic test" {
    expect(true);
}

test "General: simple comptime comparison" {
    const a = 8;
    comptime {
        expect(a == 8);
    }
}

test "General: accumulate at comptime" {
    const a = comptime accum: {
        comptime var sum = 0;
        comptime var i = 0;
        while (i < 10) {
            sum += i;
            i += 1;
        }
        break :accum sum;
    };
    comptime {
        expect(a == 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9);
    }
}
