const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");
const Display = @import("arcade-display.zig").ArcadeDisplay;

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
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        try display.draw();
    }
}
