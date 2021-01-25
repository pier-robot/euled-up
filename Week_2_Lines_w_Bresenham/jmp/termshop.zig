const std = @import("std");

// TODO
//  * Replace i8 with u8 for the screen.
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
const screen_size : i8 = 10;

pub fn update_screen(screen : *[screen_size][screen_size]i8, line : Line2Di) !void {

    var x0 = line.pt1.x;
    var x1 = line.pt2.x;
    var y0 = line.pt1.y;
    var y1 = line.pt2.y;

    // http://rosettacode.org/wiki/Category:C
    var dx: i8 = try std.math.absInt(x0 - x1);
    var dy: i8 = try std.math.absInt(y0 - y1);

    var sx: i8 = if (x0 < x1) 1 else -1;
    var sy: i8 = if (y0 < y1) 1 else -1;

    // Need to cast the i8 to f32
    var err: i8 = if (dx>dy) dx else -dy;
    var e2: i8 = err;

    while (true) {
        // We are currently using signed, but for array look-ups the values have
        // to be unsigned.
        var pix_x = @intCast(usize, x0);
        var pix_y = @intCast(usize, y0);

        screen[pix_x][pix_y] = 1;
        if (x0==x1 and y0==y1)
            break;
        e2 = err;
        if (e2 > -dx*2) {
            err -= dy*2;
            x0 += sx;
        }
        if (e2 < dy*2) {
            err += dx*2;
            y0 += sy;
        }
    }
    return;
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
    
    // Create two points and a line
    var pt_0 = Point2Di {
        .x = 8,
        .y = 1,
    };
    
    var pt_1 = Point2Di {
        .x = 1,
        .y = 5,
    };
    
    var line = Line2Di {
        .pt1 = pt_0,
        .pt2 = pt_1,
    };

    // Update the screen.
    // Note funtion parameters are immutable. (The Zig documentation mentions this in
    // passing and is somewhat missable. Zig Learn docs however have it in bold. :)
    try update_screen(&screen, line);

    // Make some X's
    screen[@intCast(u8,pt_0.x)][@intCast(u8,pt_0.y)] = 2;
    screen[@intCast(u8,pt_1.x)][@intCast(u8,pt_1.y)] = 2;
    
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
