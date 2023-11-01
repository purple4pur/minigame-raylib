const rl = @import("raylib");

pub const Side = enum { p1, p2 };

pub fn pixelSpeed(speed: f32) f32 {
    return speed * 120.0 / @as(f32, @floatFromInt(rl.getFPS()));
}
