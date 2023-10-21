const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");
const rlg = @import("raylib-object-group.zig");
const Bar = @import("keyoverlay-bar.zig").Bar;
const Kps = @import("kps.zig").Kps;
const Chart = @import("chart.zig").Chart;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    rl.initWindow(450, 400, "Speedtest [purple4pur]");
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

    var kps = Kps.init(allocator, 4, 270, 110, 20, rl.Color.dark_gray);
    defer kps.deinit();

    var chart = Chart.init(allocator, 15, 140, 420, 150, 20);
    defer chart.deinit();

    // groupLegend
    // -----------
    //{{{
    var groupLegend = rlg.ObjectGroup.init(allocator, 20, 305);
    defer groupLegend.deinit();

    try groupLegend.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = 60,
        .height = 20,
    } }, .properties = &.{ .color = rl.Color.gold } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("BPM")))),
    }, .properties = &.{
        .x = 70,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("now:")))),
    }, .properties = &.{
        .x = 230,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var bpmNowText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &bpmNowText, .properties = &.{
        .x = 280,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("max:")))),
    }, .properties = &.{
        .x = 330,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var bpmMaxText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &bpmMaxText, .properties = &.{
        .x = 380,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 30,
        .width = 60,
        .height = 20,
    } }, .properties = &.{ .color = rl.Color.sky_blue } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("Avg. BPM (2s)")))),
    }, .properties = &.{
        .x = 70,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("now:")))),
    }, .properties = &.{
        .x = 230,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm2sNowText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &avgBpm2sNowText, .properties = &.{
        .x = 280,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("max:")))),
    }, .properties = &.{
        .x = 330,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm2sMaxText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &avgBpm2sMaxText, .properties = &.{
        .x = 380,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 60,
        .width = 60,
        .height = 20,
    } }, .properties = &.{ .color = rl.Color.purple } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("Avg. BPM (5s)")))),
    }, .properties = &.{
        .x = 70,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("now:")))),
    }, .properties = &.{
        .x = 230,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm5sNowText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &avgBpm5sNowText, .properties = &.{
        .x = 280,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast(@ptrCast(@alignCast("max:")))),
    }, .properties = &.{
        .x = 330,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm5sMaxText = rlg.DrawableObject{ .text = @constCast(@ptrCast(@alignCast("0"))) };
    try groupLegend.add(&.{ .object = &avgBpm5sMaxText, .properties = &.{
        .x = 380,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });
    //}}}

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
        chart.update(0.7);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);

        k1Bar.draw();
        k2Bar.draw();
        groupK1.drawAll();
        groupK2.drawAll();

        try kps.drawKps(&buffer, "kps: {}");
        try kps.drawMaxKps(&buffer, "max: {}", 90, 0);

        chart.draw();
        bpmNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.bpm});
        bpmMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxBpm});
        avgBpm2sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm2s});
        avgBpm2sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm2s});
        avgBpm5sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm5s});
        avgBpm5sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm5s});
        groupLegend.drawAll();
    }
}
