const std = @import("std");
const math = std.math;
const rand = std.rand;
const rl = @import("raylib");
const rlm = @import("raylib-math");

pub const Ball = struct {
    const Self = @This();

    random: rand.Random,
    position: rl.Vector2 = undefined,
    speed: rl.Vector2 = undefined,

    pub fn init(random: rand.Random) Self {
        return Self{ .random = random };
    }

    pub fn newRound(self: *Self, player: enum { p1, p2 }) void {
        //{{{
        switch (player) {
            .p1 => {
                self.position = .{ .x = 5, .y = 16 };
                self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                    .{ .x = 0, .y = -1 },
                    math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
                ), 0.20 + 0.10 * self.random.float(f32));
            },
            .p2 => {
                self.position = .{ .x = 58, .y = 16 };
                self.speed = rlm.vector2Scale(rlm.vector2Rotate(
                    .{ .x = 0, .y = -1 },
                    -3 * math.pi / 4.0 + math.pi / 2.0 * self.random.float(f32),
                ), 0.20 + 0.10 * self.random.float(f32));
            },
        }
        //}}}
    }

    pub fn update(self: *Self) void {
        self.position = rlm.vector2Add(self.position, self.speed);
    }
};
