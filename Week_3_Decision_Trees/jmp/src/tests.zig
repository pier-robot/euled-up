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

test "General: slicing" {
    const a = [_]u8{ 0, 1, 2, 3, 4 };
    var slice = a[0..2];
    expect(slice[slice.len - 1] == 1);
    expect(@TypeOf(slice) == *const [2]u8);
}

test "General: list terminators" {
    const a = [_:10]u8{ 0, 1, 2, 10, 4, 5, 6 };

    var slice = a[0..:10];
    expect(slice[slice.len - 1] == 6);

    var last_item: u8 = undefined;
    for (a) |item| {
        last_item = item;
    }
    expect(last_item == 6);
    expect(a[a.len] == 10);
}

test "General: array copying" {
    var a = [_]u8{1} ** 5;
    var b = a;
    b[3] = 2;
    expect(a[3] == 1);
}
