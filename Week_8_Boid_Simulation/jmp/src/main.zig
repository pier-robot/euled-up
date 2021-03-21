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
    return std.math.sqrt(vecLengthSqr(vec));
}

fn vecLengthSqr(vec: ray.Vector2) f32 {
    return vec.x * vec.x + vec.y * vec.y;
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
            .x = self.pos.x + (vel_n.x * 10.0),
            .y = self.pos.y + (vel_n.y * 10.0),
        };
        var tail_1 = ray.Vector2{
            .x = self.pos.x + (vel_n.y * 5.0),
            .y = self.pos.y + (-vel_n.x * 5.0),
        };
        var tail_2 = ray.Vector2{
            .x = self.pos.x + (-vel_n.y * 5.0),
            .y = self.pos.y + (vel_n.x * 5.0),
        };

        // Counter clockwise
        ray.DrawTriangle(tip, tail_1, tail_2, self.col);
    }

    fn move(self: *Boid, velScale: f32) void {
        var vel = self.vel;
        if (self.limit > 0) {
            var n_vel = normalize(vel);
            var scale = std.math.min(self.limit, vecLength(vel));
            vel = vecScale(n_vel, scale);
        }
        self.pos = vecAdd(self.pos, vecScale(vel, velScale));
    }
};

fn centroidRule(boid: *Boid, weight: f32, centroid: ray.Vector2, boids: []Boid) ray.Vector2 {
    var num_boids: f32 = @intToFloat(f32, boids.len);
    // remove from average
    // (avg*num - val)/(new_count)
    var others_centroid = vecScale(vecSub(vecScale(centroid, num_boids), boid.pos), 1.0 / (num_boids - 1));
    return vecScale(vecSub(others_centroid, boid.pos), weight);
}

fn avoidanceRule(boid: *Boid, radius: f32, boids: []Boid) ray.Vector2 {
    var c = ray.Vector2{ .x = 0.0, .y = 0.0 };
    var rad_sqr = radius*radius;
    for (boids) |other_boid| {
        if (boid.id == other_boid.id) continue;
        var dist_sqr = vecLengthSqr(vecSub(boid.pos, other_boid.pos));
        if (dist_sqr < rad_sqr) {
            c = vecSub(c, vecSub(other_boid.pos, boid.pos));
            // c = vecScale(c, 1.0 - dist_sqr/rad_sqr);
            c = vecScale(c, 1.0/std.math.sqrt(rad_sqr-dist_sqr));
        }
    }

    return c;
}

fn velocityMatchRule(boid: *Boid, weight: f32, avg_vel: ray.Vector2, boids: []Boid) ray.Vector2 {
    var num_boids: f32 = @intToFloat(f32, boids.len);
    var others_vel = vecScale(vecSub(vecScale(avg_vel, num_boids), boid.vel), 1.0 / (num_boids - 1));
    return vecScale(vecSub(others_vel, boid.vel), weight);
}

fn mouseTargetRule(boid: *Boid, weight: f32, boids: []Boid) ray.Vector2 {
    if (!ray.IsMouseButtonDown(0)) return ray.Vector2 {.x=0, .y=0};
    
    var mouse_pos = ray.GetMousePosition();
    return vecScale(normalize(vecSub(mouse_pos, boid.pos)), weight);
}

fn avoidBordersRule(boid: *Boid, weight: f32, padding: f32) ray.Vector2 {
    var vel = ray.Vector2 { .x=0, .y=0 };
    if ( boid.pos.x < -padding ) {
        vel.x = 1;
    } else if ( boid.pos.x > @intToFloat(f32,screen_width)+padding ) {
        vel.x = -1;
    }
    if ( boid.pos.y < -padding ) {
        vel.y = 1;
    } else if ( boid.pos.y > @intToFloat(f32,screen_height)+padding ) {
        vel.y = -1;
    }
    return vecScale(vel, weight);
}

fn apply_rules(boids: []Boid) void {

    var centroid: ray.Vector2 = ray.Vector2{ .x = 0, .y = 0 };
    var avg_vel: ray.Vector2 = ray.Vector2{ .x = 0, .y = 0 };

    for (boids) |*boid| {
        centroid = vecAdd(centroid, boid.pos);
        avg_vel = vecAdd(avg_vel, boid.vel);
    }
    centroid = vecScale(centroid, 1.0 / @intToFloat(f32, boids.len));
    avg_vel = vecScale(avg_vel, 1.0 / @intToFloat(f32, boids.len));

    for (boids) |*boid| {
        var v1 = centroidRule(boid, 0.01, centroid, boids);
        var v2 = avoidanceRule(boid, 30.0, boids);
        var v3 = velocityMatchRule(boid, 0.12, avg_vel, boids);
        var v4 = mouseTargetRule(boid, 5, boids);
        var v5 = avoidBordersRule(boid, 10, -10);

        boid.vel = vecAdd(boid.vel, v1);
        boid.vel = vecAdd(boid.vel, vecScale(v2, 10));
        boid.vel = vecAdd(boid.vel, v3);
        boid.vel = vecAdd(boid.vel, v4);
        boid.vel = vecAdd(boid.vel, v5);
    }
}

const screen_width: i32 = 1920;
const screen_height: i32 = 1080;
const num_of_boids = 1000;

pub fn main() anyerror!void {

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
            boid.move(0.5);
            boid.draw();
        }

        ray.DrawFPS(50, 50);
        ray.EndDrawing();
    }
}

test "float fun" {
    std.testing.expect((1000.00001 * 5000.0) / 5000.0 == 1000.00001);
    std.testing.expect((1000.000001 * 5000.0) / 5000.0 != 1000.000001);
}
