const std = @import("std");
const math = std.math;
const rl = @import("raylib");
const Side = @import("common.zig").Side;
const pixelSpeed = @import("common.zig").pixelSpeed;

pub const BothPlayers = struct {
    const Self = @This();

    worldWidth: u32,
    worldHeight: u32,
    size: u16,
    p1: Player,
    p2: Player,

    pub fn init(worldWidth: u32, worldHeight: u32, size: u16) Self {
        //{{{
        return Self{
            .worldWidth = worldWidth,
            .worldHeight = worldHeight,
            .size = size,
            .p1 = Player.init(
                worldWidth,
                worldHeight,
                1,
                @as(f32, @floatFromInt(worldHeight / 2 - size / 2)),
                size,
            ),
            .p2 = Player.init(
                worldWidth,
                worldHeight,
                @as(f32, @floatFromInt(worldWidth - 2)),
                @as(f32, @floatFromInt((worldHeight / 2 - size / 2))),
                size,
            ),
        };
        //}}}
    }

    pub fn getServeSide(self: Self) Side {
        return if ((self.p1.score + self.p2.score) / 2 % 2 == 0) .p1 else .p2;
    }

    pub fn restart(self: *Self) void {
        //{{{
        self.p1.score = 0;
        self.p2.score = 0;
        self.p1.y = @as(f32, @floatFromInt(self.worldHeight / 2 - self.size / 2));
        self.p2.y = @as(f32, @floatFromInt(self.worldHeight / 2 - self.size / 2));
        //}}}
    }
};

pub const Player = struct {
    const Self = @This();

    worldWidth: f32,
    worldHeight: f32,
    x: f32,
    y: f32,
    size: f32,
    score: u16 = 0,

    fn init(worldWidth: u32, worldHeight: u32, x: f32, y: f32, size: u16) Self {
        //{{{
        return Self{
            .worldWidth = @as(f32, @floatFromInt(worldWidth)),
            .worldHeight = @as(f32, @floatFromInt(worldHeight)),
            .x = x,
            .y = y,
            .size = @as(f32, @floatFromInt(size)),
        };
        //}}}
    }

    pub fn move(self: *Self, direction: enum { up, down }, speed: f32) void {
        //{{{
        switch (direction) {
            .up => self.y -= pixelSpeed(speed),
            .down => self.y += pixelSpeed(speed),
        }
        self.y = math.clamp(self.y, 0, self.worldHeight - self.size);
        //}}}
    }

    pub fn getRectangle(self: Self) rl.Rectangle {
        //{{{
        return rl.Rectangle{
            .x = self.x,
            .y = self.y,
            .width = 1,
            .height = self.size,
        };
        //}}}
    }

    pub fn scores(self: *Self) void {
        self.score += 1;
    }
};
