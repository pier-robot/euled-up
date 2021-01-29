const std = @import("std");

// TODO
//  * Is my comptime array initialization actually comptime?
//  * Is there a better way to initialize a N-dimensional array at comptime?
//  * Is a pointer to the screen array the idiomatic way to handle this in zig?

// Generic point struct
fn Point2D(comptime T: type) type {
    return struct {
        x: T,
        y: T,
    };
}

// Generic line struct
fn Line2D(comptime T: type) type {
    return struct {
        pt1: Point2D(T),
        pt2: Point2D(T),
    };
}

// Create signed 8-bit integer versions of the structs
const Point2Di = Point2D(i8);
const Line2Di = Line2D(i8);

// lobal screen size (x and y dimensions)
const screen_size: i8 = 30;
const random_lines: u8 = 10;
const random_seed = 40;

fn draw_line(screen: *[screen_size][screen_size]i8, line: Line2Di) !void {
    var x0 = line.pt1.x;
    var x1 = line.pt2.x;
    var y0 = line.pt1.y;
    var y1 = line.pt2.y;

    // http://rosettacode.org/wiki/Category:C
    var dx: i8 = try std.math.absInt(x0 - x1);
    var dy: i8 = try std.math.absInt(y0 - y1);

    var sx: i8 = if (x0 < x1) 1 else -1;
    var sy: i8 = if (y0 < y1) 1 else -1;

    // Original method calls for a divide by 2, but instead
    // we'll scale the dx/dy by 2 instead.
    var err: i8 = (if (dx > dy) dx else -dy);
    dx *= 2;
    dy *= 2;
    var e2: i8 = err;
    while (true) {
        // We are currently using signed, but for array look-ups the values have
        // to be unsigned.
        screen[@intCast(usize, y0)][@intCast(usize, x0)] = 1;
        if (x0 == x1 and y0 == y1)
            break;
        e2 = err;
        if (e2 > -dx) {
            err -= dy;
            x0 += sx;
        }
        if (e2 < dy) {
            err += dx;
            y0 += sy;
        }
    }

    // Make some X's
    screen[@intCast(u8, line.pt1.y)][@intCast(u8, line.pt1.x)] = 2;
    screen[@intCast(u8, line.pt2.y)][@intCast(u8, line.pt2.x)] = 2;

    return;
}

fn create_line(rand: anytype, size_max: i8) Line2Di {
    return Line2Di{
        .pt1 = Point2Di{
            .x = rand.random.intRangeAtMost(i8, 0, size_max),
            .y = rand.random.intRangeAtMost(i8, 0, size_max),
        },
        .pt2 = Point2Di{
            .x = rand.random.intRangeAtMost(i8, 0, size_max),
            .y = rand.random.intRangeAtMost(i8, 0, size_max),
        },
    };
}

pub fn main() !void {

    // Initialize the multidimensional array at compile time
    var screen = comptime init: {
        var initial_screen: [screen_size][screen_size]i8 = undefined;
        for (initial_screen) |*row| {
            row.* = [_]i8{0} ** screen_size;
        }
        break :init initial_screen;
    };
    std.testing.expect(screen[5][5] == 0);

    var rand = std.rand.DefaultPrng.init(random_seed);
    var i: u8 = 0;

    while (i < random_lines) : (i += 1) {
        var rand_line = create_line(&rand, screen_size - 1);
        try draw_line(&screen, rand_line);
    }

    for (screen) |row| {
        for (row) |pixel| {
            if (pixel == 1) {
                std.debug.print("{s}", .{"\u{2588}"});
            } else if (pixel == 2) {
                std.debug.print("X", .{});
            } else {
                std.debug.print("{s}", .{"\u{2592}"});
            }
        }
        std.debug.print("\n", .{});
    }
}
