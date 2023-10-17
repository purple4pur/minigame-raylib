const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");
const rlg = @import("raylib-object-group.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    rl.initWindow(450, 400, "Speedtest");
    defer rl.closeWindow();

    rl.setTargetFPS(240);

    // groupK1
    // -------
    //{{{
    var groupK1 = rlg.ObjectGroup.init(allocator, 400, 10);
    defer groupK1.deinit();

    try groupK1.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = 40,
        .height = 40,
    } }, .properties = &.{ .color = rl.Color.dark_gray } });

    var k1BgProp = rlg.ObjectProperties{ .color = rl.Color.white };
    try groupK1.add(&.{ .object = &.{ .rectangle = .{
        .x = 5,
        .y = 5,
        .width = 30,
        .height = 30,
    } }, .properties = &k1BgProp });

    var k1Text = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("z"))) };
    var k1TextProp = rlg.ObjectProperties{
        .x = 20 - @divFloor(rl.measureText(k1Text.text, 20), 2),
        .y = 9,
        .size = 20,
        .color = rl.Color.dark_gray,
    };
    try groupK1.add(&.{ .object = &k1Text, .properties = &k1TextProp });
    //}}}

    // groupK2
    // -------
    //{{{
    var groupK2 = rlg.ObjectGroup.init(allocator, 400, 60);
    defer groupK2.deinit();

    try groupK2.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = 40,
        .height = 40,
    } }, .properties = &.{ .color = rl.Color.dark_gray } });

    var k2BgProp = rlg.ObjectProperties{ .color = rl.Color.white };
    try groupK2.add(&.{ .object = &.{ .rectangle = .{
        .x = 5,
        .y = 5,
        .width = 30,
        .height = 30,
    } }, .properties = &k2BgProp });

    var k2Text = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("x"))) };
    var k2TextProp = rlg.ObjectProperties{
        .x = 20 - @divFloor(rl.measureText(k2Text.text, 20), 2),
        .y = 9,
        .size = 20,
        .color = rl.Color.dark_gray,
    };
    try groupK2.add(&.{ .object = &k2Text, .properties = &k2TextProp });
    //}}}

    while (!rl.windowShouldClose()) {
        k1BgProp.color = if (rl.isKeyDown(rl.KeyboardKey.key_z)) rl.Color.yellow else rl.Color.white;
        k2BgProp.color = if (rl.isKeyDown(rl.KeyboardKey.key_x)) rl.Color.yellow else rl.Color.white;

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        groupK1.drawAll();
        groupK2.drawAll();
    }
}
