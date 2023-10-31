const rl = @import("raylib");

pub fn Sprite(comptime width: comptime_int, comptime height: comptime_int) type {
    return [height][width]rl.Color;
}

const O = rl.Color.blank;
const X = rl.Color.black;

pub const numbers = [_]Sprite(4, 5){
    .{
        // 0
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, O, O, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // 1
        .{ O, O, X, O },
        .{ O, X, X, O },
        .{ O, O, X, O },
        .{ O, O, X, O },
        .{ O, X, X, X },
    },
    .{
        // 2
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
    },
    .{
        // 3
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // 4
        .{ X, O, O, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ O, O, O, X },
    },
    .{
        // 5
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // 6
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // 7
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ O, O, X, O },
        .{ O, X, O, O },
        .{ O, X, O, O },
    },
    .{
        // 8
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // 9
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
        .{ O, O, O, X },
        .{ X, X, X, X },
    },
    .{
        // A
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, X, X, X },
        .{ X, O, O, X },
        .{ X, O, O, X },
    },
    .{
        // B
        .{ X, X, X, O },
        .{ X, O, O, X },
        .{ X, X, X, O },
        .{ X, O, O, X },
        .{ X, X, X, O },
    },
    .{
        // C
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, O, O, O },
        .{ X, O, O, O },
        .{ X, X, X, X },
    },
    .{
        // D
        .{ X, X, X, O },
        .{ X, O, O, X },
        .{ X, O, O, X },
        .{ X, O, O, X },
        .{ X, X, X, O },
    },
    .{
        // E
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
    },
    .{
        // F
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, X, X, X },
        .{ X, O, O, O },
        .{ X, O, O, O },
    },
};
