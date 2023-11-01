const std = @import("std");
const math = std.math;
const mem = std.mem;
const rand = std.rand;
const rl = @import("raylib");
const Display = @import("arcade-display.zig").ArcadeDisplay;
const numbers = @import("sprites.zig").numbers;
const NumSprite = @TypeOf(numbers[0]);
const Side = @import("common.zig").Side;
const BothPlayers = @import("player.zig").BothPlayers;
const Ball = @import("ball.zig").Ball;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var prng = rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const random = prng.random();

    const screenWidth = 640;
    const screenHeight = 320;

    rl.initWindow(screenWidth, screenHeight, "Pong");
    defer rl.closeWindow();
    rl.setTargetFPS(120);

    var display = Display.init(allocator, 0, 0, 64, 32, 10);
    defer display.deinit();
    try display.create();

    var bothPlayers = BothPlayers.init(64, 32, 6);
    const p1 = &bothPlayers.p1;
    const p2 = &bothPlayers.p2;

    var ball = Ball.init(random, 64, 32);
    var service: Side = .p1;
    ball.newRound(service, bothPlayers);

    while (!rl.windowShouldClose()) {
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            if (!ball.go and service == .p1) ball.start();
            p1.move(.up, 0.4);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            if (!ball.go and service == .p1) ball.start();
            p1.move(.down, 0.4);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
            if (!ball.go and service == .p2) ball.start();
            p2.move(.up, 0.4);
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
            if (!ball.go and service == .p2) ball.start();
            p2.move(.down, 0.4);
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            bothPlayers.resetScore();
            service = .p1;
            ball.newRound(.p1, bothPlayers);
        }
        switch (ball.update(bothPlayers)) {
            .p1_score => {
                p1.scores();
                service = bothPlayers.getServeSide();
                ball.newRound(service, bothPlayers);
            },
            .p2_score => {
                p2.scores();
                service = bothPlayers.getServeSide();
                ball.newRound(service, bothPlayers);
            },
            else => {},
        }

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
        try display.addRectangleRec(p1.getRectangle(), rl.Color.white);
        try display.addRectangleRec(p2.getRectangle(), rl.Color.white);
        // add scores
        try display.addSpriteWith(NumSprite, 22, 1, numbers[p1.score / 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 27, 1, numbers[p1.score % 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 34, 1, numbers[p2.score / 10], rl.Color.white);
        try display.addSpriteWith(NumSprite, 39, 1, numbers[p2.score % 10], rl.Color.white);
        // add ball
        try display.addDotVec(ball.position, rl.Color.white);
        // draw everything
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
