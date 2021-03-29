const std = @import("std");

const ray = @cImport({
    @cInclude("raylib.h");
});

const num_bombs = 50;
const square_size = 25;
const board_size_x = 20;
const board_size_y = 20;
const board_size = board_size_x * board_size_y;

const PositionState = struct {
    is_bomb: bool = false,
    is_visible: bool = false,
    is_marked: bool = false,
};

const GameBoard = struct {
    positions: [board_size]PositionState,
    neighbouring_bombs: [board_size]u4,
    bombs: u32,
    hidden: u32,
    failed: bool,

    fn init(bombs: u32) !GameBoard {
        var board = GameBoard{
            .positions = [_]PositionState{.{}} ** board_size,
            .neighbouring_bombs = [_]u4{0} ** board_size,
            .bombs = bombs,
            .hidden = board_size,
            .failed = false,
        };

        var prng = std.rand.DefaultPrng.init(blk: {
            var seed: u64 = undefined;
            try std.os.getrandom(std.mem.asBytes(&seed));
            break :blk seed;
        });
        const rand = &prng.random;

        {
            var i: usize = 0;
            while (i < bombs) {
                var picked_pos = rand.intRangeLessThan(u32, 0, board_size);
                if (board.positions[picked_pos].is_bomb) continue;
                board.positions[picked_pos].is_bomb = true;
                i += 1;
            }
        }

        for (board.neighbouring_bombs) |*val, idx| {
            var x = idx % board_size_x;
            var y = @divFloor(idx, board_size_y);

            // corners
            if (x == 0 and y == 0) {
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x + 1].is_bomb) val.* += 1;
            } else if (x == 0 and y == board_size_y - 1) {
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x + 1].is_bomb) val.* += 1;
            } else if (x == board_size_x - 1 and y == 0) {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x - 1].is_bomb) val.* += 1;
            } else if (x == board_size_x - 1 and y == board_size_y - 1) {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x - 1].is_bomb) val.* += 1;
                // edges
            } else if (y == 0) {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x - 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x + 1].is_bomb) val.* += 1;
            } else if (y == board_size_y - 1) {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x - 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x + 1].is_bomb) val.* += 1;
            } else if (x == 0) {
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x + 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x + 1].is_bomb) val.* += 1;
            } else if (x == board_size_x - 1) {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x - 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x - 1].is_bomb) val.* += 1;
                // everything else
            } else {
                if (board.positions[idx - 1].is_bomb) val.* += 1;
                if (board.positions[idx + 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x - 1].is_bomb) val.* += 1;
                if (board.positions[idx - board_size_x + 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x - 1].is_bomb) val.* += 1;
                if (board.positions[idx + board_size_x + 1].is_bomb) val.* += 1;
            }
        }

        return board;
    }

    fn winningState(self: GameBoard) bool {
        return (self.bombs == self.hidden) and (self.failed == false);
    }

    fn setVisible(self: *GameBoard, idx: usize) bool {
        if (self.positions[idx].is_bomb) {
            self.failed = true;
            return false;
        }
        self.positions[idx].is_visible = true;
        self.hidden -= 1;
        return true;
    }

    fn revealAndCheck(self: *GameBoard, idx: usize) void {
        if (self.positions[idx].is_visible) return;
        if (!self.setVisible(idx)) {
            self.revealBoard();
            return;
        }
        if (self.neighbouring_bombs[idx] == 0) self.revealNeighbours(idx);
    }

    fn revealNeighbours(self: *GameBoard, idx: usize) void {
        var x = idx % board_size_x;
        var y = @divFloor(idx, board_size_y);

        // corners
        if (x == 0 and y == 0) {
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx + board_size_x + 1);
        } else if (x == 0 and y == board_size_y - 1) {
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx - board_size_x + 1);
        } else if (x == board_size_x - 1 and y == 0) {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx + board_size_x - 1);
        } else if (x == board_size_x - 1 and y == board_size_y - 1) {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx - board_size_x - 1);
            // edges
        } else if (y == 0) {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx + board_size_x - 1);
            self.revealAndCheck(idx + board_size_x + 1);
        } else if (y == board_size_y - 1) {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx - board_size_x - 1);
            self.revealAndCheck(idx - board_size_x + 1);
        } else if (x == 0) {
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx - board_size_x + 1);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx + board_size_x + 1);
        } else if (x == board_size_x - 1) {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx - board_size_x - 1);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx + board_size_x - 1);
            // everything else
        } else {
            self.revealAndCheck(idx - 1);
            self.revealAndCheck(idx + 1);
            self.revealAndCheck(idx - board_size_x);
            self.revealAndCheck(idx + board_size_x);
            self.revealAndCheck(idx - board_size_x - 1);
            self.revealAndCheck(idx - board_size_x + 1);
            self.revealAndCheck(idx + board_size_x - 1);
            self.revealAndCheck(idx + board_size_x + 1);
        }
    }

    fn revealBoard(self: *GameBoard) void {
        for (self.positions) |*pos| {
            if (pos.is_bomb) pos.is_visible = true;
        }
    }
};

fn indexToBox(idx: usize) ray.Rectangle {
    var x = idx % board_size_x;
    var y = @divFloor(idx, board_size_y);

    return ray.Rectangle{
        .x = @intToFloat(f32, x * square_size),
        .y = @intToFloat(f32, y * square_size),
        .width = square_size - 2,
        .height = square_size - 2,
    };
}

fn coordToIdx(x: i32, y: i32) usize {
    var board_x = @divFloor(x, square_size);
    var board_y = @divFloor(y, square_size);
    return @intCast(usize, board_y * board_size_x + board_x);
}

fn interact(board: *GameBoard) void {
    var x = ray.GetMouseX();
    var y = ray.GetMouseY();
    var idx = coordToIdx(x, y);

    if (ray.IsMouseButtonPressed(1)) {
        if (board.positions[idx].is_visible) return;
        board.positions[idx].is_marked = !board.positions[idx].is_marked;
    }
    if (ray.IsMouseButtonPressed(0)) {
        if (board.positions[idx].is_visible) return;
        board.revealAndCheck(idx);
    }
    return;
}

fn drawBoard(board: GameBoard) !void {
    for (board.positions) |pos, i| {
        var x: i32 = @intCast(i32, i % board_size_x);
        var y: i32 = @intCast(i32, @divFloor(i, board_size_y));

        // color squares first
        if (!pos.is_visible) {
            ray.DrawRectangleRec(indexToBox(i), ray.WHITE);
            if (pos.is_marked) {
                var text_size: i32 = @divFloor(ray.MeasureText("?", 20), 2);
                ray.DrawText("?", x * square_size + (25 / 2 - text_size), y * square_size + 3, 20, ray.MAROON);
            }
        } else if (pos.is_bomb) {
            ray.DrawRectangleRec(indexToBox(i), ray.RED);
        } else {
            ray.DrawRectangleRec(indexToBox(i), ray.LIGHTGRAY);
            if (board.neighbouring_bombs[i] > 0) {
                const num_str = ray.TextFormat("%d", board.neighbouring_bombs[i]);
                var text_size: i32 = @divFloor(ray.MeasureText(num_str, 20), 2);
                var color = switch (board.neighbouring_bombs[i]) {
                    1 => ray.BLUE,
                    2 => ray.DARKGREEN,
                    3 => ray.RED,
                    4 => ray.MAGENTA,
                    5 => ray.BROWN,
                    6 => ray.PURPLE,
                    7 => ray.DARKBROWN,
                    else => ray.BLACK,
                };
                ray.DrawText(num_str, x * square_size + (25 / 2 - text_size), y * square_size + 3, 20, color);
            }
        }
    }
}

fn highlightTile() void {

    var x = ray.GetMouseX();
    var y = ray.GetMouseY();
    var idx = coordToIdx(x, y);

    var rect = indexToBox(idx);
    var yellow = ray.Color{
        .r = 255,
        .g = 255,
        .b = 0,
        .a = 128 };
    ray.DrawRectangleRec(rect, yellow);
}

pub fn main() anyerror!void {
    ray.InitWindow(board_size_x * square_size, board_size_y * square_size, "SOMEBODY SET US UP THE BOMB");
    defer ray.CloseWindow();
    ray.SetExitKey(0);

    ray.SetTargetFPS(30);

    var board = try GameBoard.init(num_bombs);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);

        if (!board.failed and !board.winningState()) interact(&board);

        try drawBoard(board);

        highlightTile();

        if (board.winningState()) {
            const text_size = 50;
            const win_msg = "For great justice!";
            var text_width = ray.MeasureText(win_msg, text_size);
            var text_x = @divFloor(ray.GetScreenWidth() - text_width, 2);
            var text_y = @divFloor(ray.GetScreenHeight(), 2) - text_size / 2;
            ray.DrawText(win_msg, text_x, text_y, text_size, ray.BLACK);
        } else if (board.failed) {
            const text_size = 50;
            const win_msg = "Make your time!";
            var text_width = ray.MeasureText(win_msg, text_size);
            var text_x = @divFloor(ray.GetScreenWidth() - text_width, 2);
            var text_y = @divFloor(ray.GetScreenHeight(), 2) - text_size / 2;
            ray.DrawText(win_msg, text_x, text_y, text_size, ray.BLACK);
        }

        ray.EndDrawing();

        if (ray.IsKeyPressed(0x52)) board = try GameBoard.init(num_bombs);
        if (ray.IsKeyPressed(0x51)) return;
    }
}

test "struct test" {
    const Thing = struct {
        yes: bool = true,
        no: bool = false,
    };
    var t = Thing{ .yes = true, .no = false };

    var many_t = [_]Thing{.{ .yes = true, .no = false }} ** 5;

    var many_t2 = [_]Thing{Thing{}} ** 5;

    std.testing.expect(t.yes);
    std.testing.expect(!t.no);
    std.testing.expect(many_t[3].yes);
    std.testing.expect(many_t2[3].yes);
}
