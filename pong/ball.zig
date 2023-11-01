const std = @import("std");
const math = std.math;
const rand = std.rand;
const rl = @import("raylib");
const rlm = @import("raylib-math");
const Side = @import("common.zig").Side;
const pixelSpeed = @import("common.zig").pixelSpeed;
const BothPlayers = @import("player.zig").BothPlayers;
const Player = @import("player.zig").Player;

pub const Ball = struct {
    const Self = @This();

    random: rand.Random,
    worldWidth: f32,
    worldHeight: f32,
    position: rl.Vector2 = undefined,
    speed: rl.Vector2 = undefined,
    go: bool = false,

    pub fn init(random: rand.Random, worldWidth: u32, worldHeight: u32) Self {
        return Self{
            .random = random,
            .worldWidth = @as(f32, @floatFromInt(worldWidth)),
            .worldHeight = @as(f32, @floatFromInt(worldHeight)),
        };
    }

    pub fn newRound(self: *Self, side: Side, bp: BothPlayers) void {
        //{{{
        switch (side) {
            .p1 => {
                self.position = .{
                    .x = 5,
                    .y = bp.p1.y + bp.p1.size / 2.0,
                };
                self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                    .{ .x = 0, .y = -1 },
                    math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
                ), 0.20 + 0.10 * self.random.float(f32));
            },
            .p2 => {
                self.position = .{
                    .x = self.worldWidth - 5,
                    .y = bp.p2.y + bp.p2.size / 2.0,
                };
                self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                    .{ .x = 0, .y = -1 },
                    -3 * math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
                ), 0.20 + 0.10 * self.random.float(f32));
            },
        }
        self.go = false;
        //}}}
    }

    pub fn update(self: *Self, bp: BothPlayers) enum { flying, p1_score, p2_score } {
        //{{{
        if (!self.go) return .flying;

        const prevPos = self.position;
        self.position = rlm.vector2Add(self.position, rlm.vector2Scale(
            self.speed,
            pixelSpeed(1),
        ));
        const currPos = self.position;

        if (playerHasCatch(bp.p1, prevPos, currPos)) {
            self.position.x = bp.p1.x;
            self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                .{ .x = 0, .y = -1 },
                math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
            ), 0.20 + 0.30 * self.random.float(f32));
            self.position = rlm.vector2Add(self.position, rlm.vector2Scale(
                self.speed,
                pixelSpeed(1),
            ));
        } else if (playerHasCatch(bp.p2, prevPos, currPos)) {
            self.position.x = bp.p2.x;
            self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                .{ .x = 0, .y = -1 },
                -3 * math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
            ), 0.20 + 0.30 * self.random.float(f32));
            self.position = rlm.vector2Add(self.position, rlm.vector2Scale(
                self.speed,
                pixelSpeed(1),
            ));
        }

        if (self.position.y < 0) {
            self.position.y = -self.position.y;
            self.speed.y = -self.speed.y;
        } else if (self.position.y >= self.worldHeight) {
            self.position.y = 2 * self.worldHeight - self.position.y;
            self.speed.y = -self.speed.y;
        }

        if (self.position.x < 0) {
            self.go = false;
            return .p2_score;
        } else if (self.position.x >= self.worldWidth) {
            self.go = false;
            return .p1_score;
        }
        return .flying;
        //}}}
    }

    fn playerHasCatch(p: Player, prev: rl.Vector2, curr: rl.Vector2) bool {
        //{{{
        // loose judgement. Check for:
        //   1. the ball crosses the player's line
        //   2. previous or current position.y is inside [player.y, player.y+player.size]
        return ((p.x - prev.x) * (p.x - curr.x) <= 0 and
            ((prev.y >= p.y and prev.y <= p.y + p.size) or (curr.y >= p.y and curr.y <= p.y + p.size)));
        //}}}
    }

    pub fn start(self: *Self) void {
        self.go = true;
    }
};
