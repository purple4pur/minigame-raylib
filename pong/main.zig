const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");
const Display = @import("arcade-display.zig").ArcadeDisplay;
const numbers = @import("sprites.zig").numbers;

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

    while (!rl.windowShouldClose()) {
        try display.clear();

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        try display.draw();
    }
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
