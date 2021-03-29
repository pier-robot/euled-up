const std = @import("std");

const ray = @cImport({
    @cInclude("raylib.h");
});


const num_dots = 50000;

pub fn main() anyerror!void {

    ray.InitWindow(800, 600, "test");
    defer ray.CloseWindow();

    // Define a texture 
    var render_texture = ray.LoadRenderTexture(4, 4);
    defer ray.UnloadRenderTexture(render_texture);

    ray.BeginTextureMode(render_texture);
    ray.ClearBackground(ray.BLACK);
    ray.DrawCircle(2,2,2.0, .{.r=255,.g=255, .b=255, .a=255});
    ray.EndTextureMode();


    ray.SetExitKey(0);
    ray.SetTargetFPS(60);

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = &prng.random;

    var colors = [_] ray.Color{.{.r=0,.g=0,.b=0,.a=255}} ** num_dots;
    for (colors) |*color| {
        color.r = rand.intRangeLessThan(u8, 0, 255);
        color.g = rand.intRangeLessThan(u8, 0, 255);
        color.b = rand.intRangeLessThan(u8, 0, 255);
    }

    var draw_textures = false;

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        ray.ClearBackground(ray.BLACK);

        ray.DrawFPS(10,10);

        var i: usize = 0;
        while (i < num_dots) : (i+=1) {

            if (draw_textures) {
                ray.DrawTexture(
                    render_texture.texture, 
                    rand.intRangeLessThan(i32, 0, 800),
                    rand.intRangeLessThan(i32, 30, 600),
                    colors[i],
                );
            } else {
                ray.DrawCircle(
                    rand.intRangeLessThan(i32, 0, 800),
                    rand.intRangeLessThan(i32, 30, 600),
                    2.0,
                    colors[i],
                );
            }
        }
        ray.EndDrawing();
        if (ray.IsKeyPressed(0x20)) draw_textures = !draw_textures;
    }    
}
