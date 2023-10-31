const std = @import("std");
const math = std.math;
const mem = std.mem;
const rl = @import("raylib");
const Display = @import("arcade-display.zig").ArcadeDisplay;
const numbers = @import("sprites.zig").numbers;
const NumSprite = @TypeOf(numbers[0]);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const screenWidth = 640;
    const screenHeight = 320;

    rl.initWindow(screenWidth, screenHeight, "Pong");
    defer rl.closeWindow();
    rl.setTargetFPS(120);

    var display = Display.init(allocator, 0, 0, 64, 32, 10);
    defer display.deinit();
    try display.create();

    const playerWidth = 4;
    var p1Position: f32 = 16 - playerWidth / 2;
    var p2Position: f32 = 16 - playerWidth / 2;
    var p1Score: u16 = 0;
    var p2Score: u16 = 0;

    while (!rl.windowShouldClose()) {
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) p1Position -= pixelSpeed(0.4);
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) p1Position += pixelSpeed(0.4);
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) p2Position -= pixelSpeed(0.4);
        if (rl.isKeyDown(rl.KeyboardKey.key_down)) p2Position += pixelSpeed(0.4);
        p1Position = math.clamp(p1Position, 0, 32 - playerWidth);
        p2Position = math.clamp(p2Position, 0, 32 - playerWidth);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        try display.clear();
        // add net
        var i: usize = 0;
        while (i <= 32) : (i += 3) {
            try display.addRectangle(32, i, 1, 2, rl.Color.white);
        }
        // add players
        try display.addRectangle(1, @intFromFloat(p1Position), 1, playerWidth, rl.Color.white);
        try display.addRectangle(62, @intFromFloat(p2Position), 1, playerWidth, rl.Color.white);
        // add scores
        try display.addSpriteWith(NumSprite, 22, 1, numbers[p1Score / 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 27, 1, numbers[p1Score % 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 34, 1, numbers[p2Score / 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 39, 1, numbers[p2Score % 10], rl.Color.white);
        // draw everything
        try display.draw();
    }
}

fn pixelSpeed(speed: f32) f32 {
    return speed * 120.0 / @as(f32, @floatFromInt(rl.getFPS()));
}

test "all numbers" {
    //{{{
    const allocator = std.testing.allocator;

    const screenWidth = 640;
    const screenHeight = 320;

    rl.initWindow(screenWidth, screenHeight, "Pong");
    defer rl.closeWindow();
    rl.setTargetFPS(120);

    var display = Display.init(allocator, 0, 0, 64, 32, 10);
    defer display.deinit();
    try display.create();

    while (!rl.windowShouldClose()) {
        try display.clear();

        for (0..10) |i| {
            try display.addSprite(@TypeOf(numbers[i]), i * 5, 0, numbers[i]);
        }
        for (0..6) |i| {
            try display.addSprite(@TypeOf(numbers[i + 10]), i * 5, 7, numbers[i + 10]);
        }

        for (0..10) |i| {
            try display.addSpriteWith(@TypeOf(numbers[i]), i * 5, 14, numbers[i], rl.Color.red);
        }
        for (0..6) |i| {
            try display.addSpriteWith(@TypeOf(numbers[i + 10]), i * 5, 21, numbers[i + 10], rl.Color.blue);
        }

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        try display.draw();
    }
    //}}}
}
