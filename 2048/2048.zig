const std = @import("std");
const math = std.math;
const mem = std.mem;
const rand = std.rand;
const print = std.debug.print;

const rl = @import("raylib");

const Grid = @import("grid.zig").Grid;
const i32FromFloat = @import("grid.zig").i32FromFloat;

const ColorMapPair = struct { brick: rl.Color, text: rl.Color };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var prng = rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const random = prng.random();

    // TODO: read config from stdin
    const gridSize = 4;
    const brickWidth = 70;
    const brickSpace = 5;
    const brickMargin = 20;
    const fontSize = 20;

    var grid = Grid.init(allocator, random, gridSize, brickWidth, brickSpace, brickMargin);
    defer grid.deinit();
    try grid.createGrid();

    var newBrickFlag: u128 = 0;

    grid.starting = 2; // start a game with minimal value 1 (optional)
    _ = try grid.generate();

    const screenWidth = brickMargin * 2 + brickWidth * gridSize + brickSpace * (gridSize - 1);
    const screenHeight = screenWidth; // TODO: more margin for score, steps etc.

    rl.initWindow(screenWidth, screenHeight, "The 2048 game");
    defer rl.closeWindow();
    rl.setTargetFPS(30);

    var buf: [32]u8 = undefined;

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            newBrickFlag = try grid.newGame();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_up) or rl.isKeyPressed(rl.KeyboardKey.key_w)) {
            // TODO: detect a dead game
            if (try grid.move(.up)) {
                newBrickFlag = try grid.generate();
            }
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_down) or rl.isKeyPressed(rl.KeyboardKey.key_s)) {
            if (try grid.move(.down)) {
                newBrickFlag = try grid.generate();
            }
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_left) or rl.isKeyPressed(rl.KeyboardKey.key_a)) {
            if (try grid.move(.left)) {
                newBrickFlag = try grid.generate();
            }
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_right) or rl.isKeyPressed(rl.KeyboardKey.key_d)) {
            if (try grid.move(.right)) {
                newBrickFlag = try grid.generate();
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        const g = try grid.getGrid();
        const v = try grid.getValues();

        for (g, 0..) |line, row| {
            for (line, 0..) |brick, col| {
                const value = v[row][col];
                if (value == 0) continue;

                const color = colorMap(value);
                rl.drawRectangleRec(brick, color.brick);

                // draw outlines for new generated bricks
                if (newBrickFlag & math.shl(u128, 1, row * gridSize + col) != 0) {
                    rl.drawRectangleLinesEx(brick, 4, rl.Color.red);
                }

                const text = try std.fmt.bufPrintZ(&buf, "{d}", .{value});
                const textWidth = rl.measureText(text, fontSize);
                rl.drawText(
                    text,
                    i32FromFloat(brick.x) + @divFloor((brickWidth - textWidth), 2),
                    i32FromFloat(brick.y) + @divFloor((brickWidth - fontSize), 2),
                    fontSize,
                    color.text,
                );
            }
        }
    }
}

fn colorMap(value: u16) ColorMapPair {
    //{{{
    return switch (value) {
        0 => .{ .brick = rl.Color.blank, .text = rl.Color.blank },
        1 => .{ .brick = rl.Color.yellow, .text = rl.Color.dark_gray },
        2 => .{ .brick = rl.Color.gold, .text = rl.Color.dark_gray },
        4 => .{ .brick = rl.Color.orange, .text = rl.Color.dark_gray },
        8 => .{ .brick = rl.Color.sky_blue, .text = rl.Color.dark_gray },
        16 => .{ .brick = rl.Color.blue, .text = rl.Color.ray_white },
        32 => .{ .brick = rl.Color.dark_blue, .text = rl.Color.ray_white },
        64 => .{ .brick = rl.Color.purple, .text = rl.Color.ray_white },
        128 => .{ .brick = rl.Color.violet, .text = rl.Color.ray_white },
        256 => .{ .brick = rl.Color.dark_purple, .text = rl.Color.ray_white },
        512 => .{ .brick = rl.Color.beige, .text = rl.Color.dark_gray },
        1024 => .{ .brick = rl.Color.brown, .text = rl.Color.ray_white },
        2048 => .{ .brick = rl.Color.dark_brown, .text = rl.Color.ray_white },
        else => .{ .brick = rl.Color.dark_gray, .text = rl.Color.ray_white },
    };
    //}}}
}

test "Grid pallete" {
    //{{{
    const allocator = std.testing.allocator;
    var prng = rand.DefaultPrng.init(0);
    const random = prng.random();

    var buf: [32]u8 = undefined;

    const gridSize = 4;
    const brickWidth = 50;
    const brickSpace = 5;
    const brickMargin = 20;
    const fontSize = 20;

    var grid = Grid.init(allocator, random, gridSize, brickWidth, brickSpace, brickMargin);
    defer grid.deinit();
    try grid.createGrid();

    grid.values.?[0][0] = 1;
    grid.values.?[0][1] = 2;
    grid.values.?[0][2] = 4;
    grid.values.?[0][3] = 8;
    grid.values.?[1][0] = 16;
    grid.values.?[1][1] = 32;
    grid.values.?[1][2] = 64;
    grid.values.?[1][3] = 128;
    grid.values.?[2][0] = 256;
    grid.values.?[2][1] = 512;
    grid.values.?[2][2] = 1024;
    grid.values.?[2][3] = 2048;
    grid.values.?[3][0] = 4096;
    grid.values.?[3][1] = 8192;

    const screenWidth = brickMargin * 2 + brickWidth * gridSize + brickSpace * (gridSize - 1);
    const screenHeight = screenWidth;

    rl.initWindow(screenWidth, screenHeight, "[test] The 2048 game");
    defer rl.closeWindow();

    rl.setTargetFPS(30);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        const g = try grid.getGrid();
        const v = try grid.getValues();

        for (g, 0..) |line, row| {
            for (line, 0..) |brick, col| {
                const value = v[row][col];
                if (value == 0) continue;

                const color = colorMap(value);
                rl.drawRectangleRec(brick, color.brick);
                const text = try std.fmt.bufPrintZ(&buf, "{d}", .{value});
                const textWidth = rl.measureText(text, fontSize);
                rl.drawText(
                    text,
                    i32FromFloat(brick.x) + @divFloor((brickWidth - textWidth), 2),
                    i32FromFloat(brick.y) + @divFloor((brickWidth - fontSize), 2),
                    fontSize,
                    color.text,
                );
            }
        }
    }
    //}}}
}
