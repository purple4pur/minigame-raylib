const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");
const rlg = @import("raylib-object-group.zig");
const Bar = @import("keyoverlay-bar.zig").Bar;
const Kps = @import("kps.zig").Kps;
const Chart = @import("chart.zig").Chart;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    rl.initWindow(450, 340, "Speedtest [purple4pur]");
    defer rl.closeWindow();

    rl.setTargetFPS(360);

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

    var k1Bar = Bar.init(allocator, 0, 15, 400, 30, rl.Color.yellow);
    defer k1Bar.deinit();
    var k2Bar = Bar.init(allocator, 0, 65, 400, 30, rl.Color.yellow);
    defer k2Bar.deinit();

    var kps = Kps.init(allocator, 6, 270, 110, 20, rl.Color.dark_gray);
    defer kps.deinit();

    var chart = Chart.init(allocator, 15, 170, 420, 150, 20);
    defer chart.deinit();

    var buffer: [64]u8 = undefined;

    while (!rl.windowShouldClose()) {
        const time = rl.getTime();

        if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
            k1BgProp.color = rl.Color.yellow;
            try k1Bar.pressed();
        } else {
            k1BgProp.color = rl.Color.white;
            try k1Bar.released();
        }

        if (rl.isKeyDown(rl.KeyboardKey.key_x)) {
            k2BgProp.color = rl.Color.yellow;
            try k2Bar.pressed();
        } else {
            k2BgProp.color = rl.Color.white;
            try k2Bar.released();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.key_z)) try kps.getKeyPressed(time);
        if (rl.isKeyPressed(rl.KeyboardKey.key_x)) try kps.getKeyPressed(time);
        try kps.refreshData(time);
        try chart.receiveKps(kps);

        k1Bar.update(1.2);
        k2Bar.update(1.2);
        chart.update(0.8);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        k1Bar.draw();
        k2Bar.draw();
        groupK1.drawAll();
        groupK2.drawAll();

        try kps.drawKps(&buffer, "kps: {}");
        try kps.drawMaxKps(&buffer, "max: {}", 90, 0);
        try kps.drawBpm(&buffer, "bpm={}", 0, 30);
        try kps.drawMaxBpm(&buffer, "max: {}", 90, 30);

        chart.draw();
    }
}
