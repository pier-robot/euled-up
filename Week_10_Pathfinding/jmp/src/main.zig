const std = @import("std");

const ray = @cImport({
    @cInclude("raylib.h");
});

const tile_size = 16;
const tile_pad = 2;

fn makeMap(comptime T: type, allocator: *std.mem.Allocator, file_path: []const u8) !std.ArrayList(T) {
    const cwd = std.fs.cwd();
    const file_handle: std.fs.File = cwd.openFile(file_path, .{ .read = true }) catch |err| {
        std.debug.print("Unable to open {s}\n", .{file_path});
        return err;
    };
    defer file_handle.close();

    const reader = std.io.bufferedReader(file_handle.reader()).reader();

    var buffer: [4096]u8 = undefined;

    var list = try std.ArrayList(T).initCapacity(allocator, 400);
    var line_num: u32 = 0;

    while (reader.readUntilDelimiterOrEof(&buffer, '\n') catch |err| {
        std.debug.print("Could not read line\n", .{});
        return err;
    }) |line| : (line_num += 1) {
        var val_iter = std.mem.tokenize(line, ",");
        while (val_iter.next()) |s_val| {
            switch (@typeInfo(T)) {
                .Float => {
                    try list.append(try std.fmt.parseFloat(T, s_val));
                },
                .Int => {
                    try list.append(try std.fmt.parseInt(T, s_val, 10));
                },
                else => {},
            }
        }
        // We'll be cheeky and update the capacity to be the square of the number
        // of columns in a row. (This assumes we have square maps and means we
        // don't need repeated reallocations
        if (line_num == 0) {
            try list.ensureCapacity(list.items.len * list.items.len);
        }
    }

    return list;
}

fn indexToBox(board_size: u32, idx: usize) ray.Rectangle {
    var x = idx % board_size;
    var y = @divFloor(idx, board_size);

    return ray.Rectangle{
        .x = @intToFloat(f32, x * tile_size),
        .y = @intToFloat(f32, y * tile_size),
        .width = tile_size - tile_pad,
        .height = tile_size - tile_pad,
    };
}

fn drawBoard(board: std.ArrayList(u1), path: std.ArrayList(u1)) !void {
    var board_size = std.math.sqrt(board.items.len);

    for (board.items) |val, i| {
        var x: i32 = @intCast(i32, i % board_size);
        var y: i32 = @intCast(i32, @divFloor(i, board_size));

        // color squares first
        if (val == 1) {
            ray.DrawRectangleRec(indexToBox(board_size, i), ray.WHITE);
        } else {
            ray.DrawRectangleRec(indexToBox(board_size, i), ray.DARKGRAY);
        }
        
        if (path.items[i] == 1) {
            ray.DrawRectangleRec(indexToBox(board_size, i), ray.Color{.r = 255, .g=255, .b=0, .a=128});
        }
    }
}

const NeighbourIterator = struct {
    index: usize = 0,
    tile: usize,
    grid_x: usize,
    grid_y: usize,

    fn next(self: *NeighbourIterator) ?usize {
        var x: i32 = @intCast(i32, self.tile % self.grid_x);
        var y: i32 = @intCast(i32, @divFloor(self.tile, self.grid_y));

        switch (self.index) {
            0 => y -= 1,
            1 => x += 1,
            2 => y += 1,
            3 => x -= 1,
            else => return null,
        }
        self.index += 1;
        if (x < 0 or x >= self.grid_x or y < 0 or y >= self.grid_y) return self.next();
        return @intCast(usize, @intCast(i32, self.grid_x) * y + x);
    }
};

fn neighbourIterator(tile: usize, grid_size: usize) NeighbourIterator {
    var side = std.math.sqrt(grid_size);
    return NeighbourIterator{
        .tile = tile,
        .grid_x = side,
        .grid_y = side,
    };
}

fn makeBFSMap(allocator: *std.mem.Allocator, start: usize, board: std.ArrayList(u1)) !std.ArrayList(usize) {
    var fifo = std.fifo.LinearFifo(usize, .{ .Static = 32 }).init();
    defer fifo.deinit();

    try fifo.writeItem(start);

    var map = std.ArrayList(usize).init(allocator);
    try map.resize(board.items.len);

    var map_length = @intCast(usize, map.items.len);
    var unchecked = map_length;

    for (map.items) |*v| v.* = unchecked;

    while (fifo.readableLength() != 0) {
        var current = fifo.readItem().?;
        var iter = neighbourIterator(current, map_length);
        while (iter.next()) |next| {
            if (board.items[next] == 0) {
                continue;
            }
            if (map.items[next] == unchecked) {
                try fifo.writeItem(next);
                map.items[next] = current;
            }
        }
    }

    return map;
}

fn makeBFSPath(allocator: *std.mem.Allocator, start: usize, end: usize, bfs: std.ArrayList(usize)) !std.ArrayList(u1) {
    var map = std.ArrayList(u1).init(allocator);
    try map.resize(bfs.items.len);
    for (map.items) |*v| v.* = 0;

    var current = end;
    map.items[current] = 1;
    var count: usize = 1;
    while (current != start) {
        current = bfs.items[current];
        map.items[current] = 1;
        count += 1;
    }
    std.debug.print("Steps: {}\n", .{count});
    return map;
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var act1 = try makeMap(u1, &arena.allocator, "../data/act1.csv");
    defer act1.deinit();
    std.debug.print("Cells: {}\n", .{act1.items.len});
    // var act2 = try makeMap(u1, &arena.allocator, "../data/act2.csv");
    // defer act2.deinit();
    // std.debug.print("Cells: {}\n", .{act2.items.len});
    // var act3 = try makeMap(u1, &arena.allocator, "../data/act3_water.csv");
    // defer act3.deinit();
    // std.debug.print("Cells: {}\n", .{act3.items.len});

    var board_size = @intCast(i32, std.math.sqrt(act1.items.len));

    var act1_bfs_map = try makeBFSMap(&arena.allocator, 0, act1);
    defer act1_bfs_map.deinit();

    var path_map = try makeBFSPath(&arena.allocator, 0, 399, act1_bfs_map);
    defer path_map.deinit();

    ray.InitWindow(board_size * tile_size, board_size * tile_size, "Zigzag");
    defer ray.CloseWindow();

    ray.SetExitKey(0);
    ray.SetTargetFPS(60);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);

        try drawBoard(act1, path_map);

        ray.DrawFPS(50, 50);
        ray.EndDrawing();
    }
}
