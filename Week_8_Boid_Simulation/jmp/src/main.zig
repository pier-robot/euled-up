const std = @import("std");

const ray = @cImport({
    @cInclude("raylib.h");
});

fn vecAdd(v1: ray.Vector2, v2: ray.Vector2) ray.Vector2 {
    return ray.Vector2{ .x = v1.x + v2.x, .y = v1.y + v2.y };
}

fn vecSub(v1: ray.Vector2, v2: ray.Vector2) ray.Vector2 {
    return ray.Vector2{ .x = v1.x - v2.x, .y = v1.y - v2.y };
}

fn vecLength(vec: ray.Vector2) f32 {
    return std.math.sqrt(vec.x * vec.x + 
                         vec.y * vec.y);
}

fn vecScale(v: ray.Vector2, scale: f32) ray.Vector2 {
    return ray.Vector2{ .x = v.x * scale, .y = v.y * scale };
}

fn normalize(vec: ray.Vector2) ray.Vector2 {
    var len = vecLength(vec);
    if (len == 0.0) len = 1.0;
    return vecScale(vec, 1.0 / len);
}

const Boid = struct {
    pos: ray.Vector2,
    vel: ray.Vector2,
    col: ray.Color = ray.LIGHTGRAY,
    id: u16 = 0,
    limit: f32 = 20,

    fn draw(self: Boid) void {
        var vel_n = normalize(self.vel);

        var tip = ray.Vector2{
            .x = self.pos.x + (vel_n.x * 20.0),
            .y = self.pos.y + (vel_n.y * 20.0),
        };
        var tail_1 = ray.Vector2{
            .x = self.pos.x + (vel_n.y * 10.0),
            .y = self.pos.y + (-vel_n.x * 10.0),
        };
        var tail_2 = ray.Vector2{
            .x = self.pos.x + (-vel_n.y * 10.0),
            .y = self.pos.y + (vel_n.x * 10.0),
        };

        // Counter clockwise
        ray.DrawTriangle(tip, tail_1, tail_2, self.col);
    }

    fn move(self: *Boid) void {
        if (self.limit == 0) {
            self.pos = vecAdd(self.pos, self.vel);
        } else {
            var n_vel = normalize(self.vel);
            var scale = std.math.min(self.limit, vecLength(self.vel));
            self.pos = vecAdd(self.pos, vecScale(n_vel, scale));
        }
    }
};

fn rule1(boid: *Boid, weight: f32, boids: []Boid) ray.Vector2 {
    var center = ray.Vector2{ .x = 0.0, .y = 0.0 };
    for (boids) |other_boid| {
        if (boid.id == other_boid.id) continue;
        center = vecAdd(center, other_boid.pos);
    }
    var num_other_boids: f32 = @intToFloat(f32, boids.len - 1);
    center = vecScale(center, 1.0 / num_other_boids);

    return vecScale(vecSub(center, boid.pos), weight);
}

fn rule2(boid: *Boid, radius: f32, boids: []Boid) ray.Vector2 {
    var c = ray.Vector2{ .x = 0.0, .y = 0.0 };
    for (boids) |other_boid| {
        if (boid.id == other_boid.id) continue;
        var dist = vecLength(vecSub(boid.pos, other_boid.pos));
        if ( dist < radius ) {
            c = vecSub(c, vecSub(other_boid.pos, boid.pos));
        }
    }

    return c;
}

fn rule3(boid: *Boid, weight: f32, boids: []Boid) ray.Vector2 {
    var vel = ray.Vector2{ .x = 0.0, .y = 0.0 };
    for (boids) |other_boid| {
        if (boid.id == other_boid.id) continue;
        vel = vecAdd(boid.vel, other_boid.vel);
    }
    var num_other_boids: f32 = @intToFloat(f32, boids.len - 1);
    vel = vecScale(vel, 1.0 / num_other_boids);

    return vecScale(vecSub(vel, boid.vel), weight);
}

fn apply_rules(boids: []Boid) void {
    for (boids) |*boid| {
        var v1 = rule1(boid, 0.001, boids);
        var v2 = rule2(boid, 30.0, boids);
        var v3 = rule3(boid, 0.12, boids);
        boid.vel = vecAdd(boid.vel, v1);
        boid.vel = vecAdd(boid.vel, vecScale(v2, 0.5));
        boid.vel = vecAdd(boid.vel, v3);
    }
}

pub fn main() anyerror!void {
    const screen_width: i32 = 1920;
    const screen_height: i32 = 1080;

    const num_of_boids = 5000;

    // Get a random number generator
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random;

    // Initialize some boids
    var boids = [_]Boid{Boid{ .pos = .{ .x = 0, .y = 0 }, .vel = .{ .x = 0, .y = 0 } }} ** num_of_boids;

    // Set starting position for boids
    for (boids) |*boid, i| {
        boid.id = @intCast(u16, i);
        boid.vel = ray.Vector2{
            .x = 10 * (rand.float(f32) * 2 - 1),
            .y = 10 * (rand.float(f32) * 2 - 1),
        };
        boid.limit = rand.float(f32) * 10 + 10;
        boid.col = ray.Color{
            .r = rand.intRangeAtMost(u8, 8, 255),
            .g = rand.intRangeAtMost(u8, 8, 255),
            .b = rand.intRangeAtMost(u8, 8, 255),
            .a = 255,
        };
        switch (rand.uintLessThan(u4, 4)) {
            // bottom
            0 => {
                //boid.pos.x = rand.float(f32) * @intToFloat(f32, screen_width);
                boid.pos.x = @intToFloat(f32, rand.uintLessThan(u32, screen_width));
                boid.pos.y = 20.0;
            },
            // top
            1 => {
                boid.pos.x = rand.float(f32) * @intToFloat(f32, screen_width);
                boid.pos.y = -20.0 + @intToFloat(f32, screen_height);
            },
            // left
            2 => {
                boid.pos.x = 20.0;
                boid.pos.y = rand.float(f32) * @intToFloat(f32, screen_height);
            },
            // right
            else => {
                boid.pos.x = -20 + @intToFloat(f32, screen_width);
                boid.pos.y = rand.float(f32) * @intToFloat(f32, screen_height);
            },
        }
    }

    ray.InitWindow(screen_width, screen_height, "window");
    defer ray.CloseWindow();
    ray.SetExitKey(0);

    ray.SetTargetFPS(60);

    var text_size: i32 = @divFloor(ray.MeasureText("Launch every zig!", 20), 2);
    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);

        ray.DrawText("Launch every zig!", screen_width / 2 - text_size, screen_height / 2, 20, ray.LIGHTGRAY);

        apply_rules(boids[0..]);

        for (boids) |*boid| {
            boid.move();
            boid.draw();
        }

        ray.DrawFPS(50, 50);
        ray.EndDrawing();
    }
}
