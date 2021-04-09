const std = @import("std");

const size = 2<<21;

fn A(a: []const i32, b: []const i32) i32 {
    var sum: i32 = 0;
    var i: u32 = 0;
    while (i<size) : (i+=1) {
        sum += a[i];
        sum += b[i];
    }

    i = 0;
    while (i<size) : (i+=1) {
        sum += a[i];
        sum += b[i];
    }
    return sum;
}

fn B(a: []const i32, b: []const i32) i32 {
    var sum: i32 = 0;
    var i: u32 = 0;
    while (i<size) : (i+=1) {
        sum += a[i];
        sum += a[i];
    }

    i = 0;
    while (i<size) : (i+=1) {
        sum += b[i];
        sum += b[i];
    }
    return sum;
}

fn C(a: []const i32, b: []const i32) i32 {

    var sum: i32 = 0;
    var i: u32 = 0;
    
    while (i<size) : (i+=1) {
        sum += a[i];
        sum += a[i];
        sum += b[i];
        sum += b[i];
    }
    return sum;
}

fn D(a: []const i32, b: []const i32) i32 {

    var sum: i32 = 0;
    var i: u32 = 0;
    
    while (i<size) : (i+=1) {
        sum += a[i];
        sum += b[i];
        sum += a[i];
        sum += b[i];
    }
    return sum;
}

fn E(a: []const i32, b: []const i32) i32 {

    var sum: i32 = 0;
    const batches = 16; // 64 / sizeof(i32)
    var i: usize = 0;
    comptime var j = 0;
    while (i < size) : (i += batches) {
        j = 0;
        inline while (j < batches) : ( j+=1 ) {
            sum += a[i+j];
            sum += a[i+j];
        }
        j = 0;
        inline while (j < batches) : ( j+=1 ) {
            sum += b[i+j];
            sum += b[i+j];
        }
    }
    return sum;
}


pub fn main() void {
    const allocator = std.heap.page_allocator;

    const args: [][:0]u8 = std.process.argsAlloc(allocator) catch unreachable;
    defer std.process.argsFree(allocator, args);

    const minus_ones = allocator.alloc(i32, size) catch unreachable;
    defer allocator.free(minus_ones);
    for (minus_ones) |*v| v.* = -1;

    const ones = allocator.alloc(i32, size) catch unreachable;
    defer allocator.free(ones);
    for (ones) |*v| v.* = 1;

    var sum: i32 = 0;
    var i: usize = 0;

    if (args.len == 2) {
        var mode: u8 = args[1][0];
        switch (mode) {
            'A' => { while (i<1000) : (i+=1) { sum += A(minus_ones, ones);}},
            'B' => { while (i<1000) : (i+=1) { sum += B(minus_ones, ones);}},
            'C' => { while (i<1000) : (i+=1) { sum += C(minus_ones, ones);}},
            'D' => { while (i<1000) : (i+=1) { sum += D(minus_ones, ones);}},
            else => {
                std.debug.print("Invalid mode\n", .{});
                return;
            },
        }
    } else {
        while (i<1000) : (i+=1) {
            sum += E(minus_ones, ones);
        }
    }
    std.debug.print("{}\n", .{sum});
}
