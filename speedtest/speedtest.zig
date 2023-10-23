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

    const screenWidth = 450;
    const screenHeight = 400;
    rl.initWindow(screenWidth, screenHeight, "Speedtest [purple4pur]");
    defer rl.closeWindow();

    rl.setTargetFPS(360);

    // groupK1
    // -------
    //{{{
    var groupK1 = rlg.ObjectGroup.init(allocator, 400, 10);
    defer groupK1.deinit();

    const k1Rectangle = rlg.DrawableObject{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = 40,
        .height = 40,
    } };
    try groupK1.add(&.{ .object = &k1Rectangle, .properties = &.{ .color = rl.Color.dark_gray } });

    var k1BgProp = rlg.ObjectProperties{ .color = rl.Color.white };
    try groupK1.add(&.{ .object = &.{ .rectangle = .{
        .x = 5,
        .y = 5,
        .width = 30,
        .height = 30,
    } }, .properties = &k1BgProp });

    var k1Binding = rl.KeyboardKey.key_z;
    var k1Text = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "Z", .{}) };
    defer allocator.free(k1Text.text);
    var k1TextProp = rlg.ObjectProperties{
        .x = 20 - @divFloor(rl.measureText(k1Text.text, 20), 2),
        .y = 11,
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

    const k2Rectangle = rlg.DrawableObject{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = 40,
        .height = 40,
    } };
    try groupK2.add(&.{ .object = &k2Rectangle, .properties = &.{ .color = rl.Color.dark_gray } });

    var k2BgProp = rlg.ObjectProperties{ .color = rl.Color.white };
    try groupK2.add(&.{ .object = &.{ .rectangle = .{
        .x = 5,
        .y = 5,
        .width = 30,
        .height = 30,
    } }, .properties = &k2BgProp });

    var k2Binding = rl.KeyboardKey.key_x;
    var k2Text = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "X", .{}) };
    defer allocator.free(k2Text.text);
    var k2TextProp = rlg.ObjectProperties{
        .x = 20 - @divFloor(rl.measureText(k2Text.text, 20), 2),
        .y = 11,
        .size = 20,
        .color = rl.Color.dark_gray,
    };
    try groupK2.add(&.{ .object = &k2Text, .properties = &k2TextProp });
    //}}}

    var k1Bar = Bar.init(allocator, 0, 15, 400, 30, rl.Color.yellow);
    defer k1Bar.deinit();
    var k2Bar = Bar.init(allocator, 0, 65, 400, 30, rl.Color.yellow);
    defer k2Bar.deinit();

    var kps = Kps.init(allocator, 270, 115, 20, rl.Color.dark_gray, 4);
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

    const Screen = enum { speedtest, k1_binding, k2_binding };
    var currentScreen: Screen = .speedtest;

    while (!rl.windowShouldClose()) {
        const time = rl.getTime();

        switch (currentScreen) {
            .speedtest => {
                //{{{
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupK1.x)) + k1Rectangle.rectangle.x,
                    .y = @as(f32, @floatFromInt(groupK1.y)) + k1Rectangle.rectangle.y,
                    .width = k1Rectangle.rectangle.width,
                    .height = k1Rectangle.rectangle.height,
                })) {
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .k1_binding;
                    }
                }

                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupK2.x)) + k2Rectangle.rectangle.x,
                    .y = @as(f32, @floatFromInt(groupK2.y)) + k2Rectangle.rectangle.y,
                    .width = k2Rectangle.rectangle.width,
                    .height = k2Rectangle.rectangle.height,
                })) {
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .k2_binding;
                    }
                }

                if (rl.isKeyDown(k1Binding)) {
                    k1BgProp.color = rl.Color.yellow;
                    try k1Bar.pressed();
                } else {
                    k1BgProp.color = rl.Color.white;
                    try k1Bar.released();
                }

                if (rl.isKeyDown(k2Binding)) {
                    k2BgProp.color = rl.Color.yellow;
                    try k2Bar.pressed();
                } else {
                    k2BgProp.color = rl.Color.white;
                    try k2Bar.released();
                }

                if (rl.isKeyPressed(k1Binding)) try kps.getKeyPressed(time);
                if (rl.isKeyPressed(k2Binding)) try kps.getKeyPressed(time);
                //}}}
            },
            .k1_binding => {
                //{{{
                const key = rl.getKeyPressed();
                if (isValidKeyCode(key)) {
                    k1Binding = key;
                    allocator.free(k1Text.text);
                    k1Text.text = try keyString(allocator, key);
                    if (isSmallText(key)) {
                        k1TextProp.size = 10;
                        k1TextProp.x = 20 - @divFloor(rl.measureText(k1Text.text, 10), 2);
                        k1TextProp.y = 15;
                    } else {
                        k1TextProp.size = 20;
                        k1TextProp.x = 20 - @divFloor(rl.measureText(k1Text.text, 20), 2);
                        k1TextProp.y = 11;
                    }
                    currentScreen = .speedtest;
                }
                //}}}
            },
            .k2_binding => {
                //{{{
                const key = rl.getKeyPressed();
                if (isValidKeyCode(key)) {
                    k2Binding = key;
                    allocator.free(k2Text.text);
                    k2Text.text = try keyString(allocator, key);
                    k2TextProp.x = 20 - @divFloor(rl.measureText(k2Text.text, 20), 2);
                    if (isSmallText(key)) {
                        k2TextProp.size = 10;
                        k2TextProp.x = 20 - @divFloor(rl.measureText(k2Text.text, 10), 2);
                        k2TextProp.y = 15;
                    } else {
                        k2TextProp.size = 20;
                        k2TextProp.x = 20 - @divFloor(rl.measureText(k2Text.text, 20), 2);
                        k2TextProp.y = 11;
                    }
                    currentScreen = .speedtest;
                }
                //}}}
            },
        }

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

        try kps.drawKps("kps: {}");
        try kps.drawMaxKps("max: {}", 90, 0);

        chart.draw();

        bpmNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.bpm});
        bpmMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxBpm});
        avgBpm2sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm2s});
        avgBpm2sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm2s});
        avgBpm5sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm5s});
        avgBpm5sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm5s});
        groupLegend.drawAll();

        switch (currentScreen) {
            .k1_binding, .k2_binding => {
                //{{{
                rl.drawRectangle(0, 0, screenWidth, screenHeight, rl.Color.light_gray.fade(0.55));
                const prompt = "Press a key for " ++ if (currentScreen == .k1_binding) "K1 binding" else "K2 binding";
                const promptWidth = rl.measureText(prompt, 20);
                rl.drawRectangle(
                    screenWidth / 2 - @divFloor(promptWidth, 2) - 10,
                    screenHeight / 2 - 15,
                    promptWidth + 20,
                    30,
                    rl.Color.dark_gray,
                );
                rl.drawText(
                    prompt,
                    screenWidth / 2 - @divFloor(promptWidth, 2),
                    screenHeight / 2 - 10,
                    20,
                    rl.Color.ray_white,
                );
                //}}}
            },
            else => {},
        }
    }
}

fn isValidKeyCode(key: rl.KeyboardKey) bool {
    //{{{
    return switch (key) {
        .key_zero,
        .key_one,
        .key_two,
        .key_three,
        .key_four,
        .key_five,
        .key_six,
        .key_seven,
        .key_eight,
        .key_nine,
        .key_apostrophe,
        .key_comma,
        .key_minus,
        .key_period,
        .key_slash,
        .key_semicolon,
        .key_equal,
        .key_a,
        .key_b,
        .key_c,
        .key_d,
        .key_e,
        .key_f,
        .key_g,
        .key_h,
        .key_i,
        .key_j,
        .key_k,
        .key_l,
        .key_m,
        .key_n,
        .key_o,
        .key_p,
        .key_q,
        .key_r,
        .key_s,
        .key_t,
        .key_u,
        .key_v,
        .key_w,
        .key_x,
        .key_y,
        .key_z,
        .key_space,
        .key_enter,
        .key_tab,
        .key_backspace,
        .key_insert,
        .key_delete,
        .key_right,
        .key_left,
        .key_down,
        .key_up,
        .key_page_up,
        .key_page_down,
        .key_home,
        .key_end,
        //.key_caps_lock,
        .key_f1,
        .key_f2,
        .key_f3,
        .key_f4,
        .key_f5,
        .key_f6,
        .key_f7,
        .key_f8,
        .key_f9,
        .key_f10,
        .key_f11,
        //.key_f12,
        .key_left_shift,
        .key_left_control,
        .key_left_alt,
        .key_right_shift,
        .key_right_control,
        .key_right_alt,
        => true,
        else => false,
    };
    //}}}
}

fn keyString(allocator: mem.Allocator, key: rl.KeyboardKey) ![:0]u8 {
    //{{{
    return switch (key) {
        .key_zero,
        .key_one,
        .key_two,
        .key_three,
        .key_four,
        .key_five,
        .key_six,
        .key_seven,
        .key_eight,
        .key_nine,
        .key_apostrophe,
        .key_comma,
        .key_minus,
        .key_period,
        .key_slash,
        .key_semicolon,
        .key_equal,
        .key_a,
        .key_b,
        .key_c,
        .key_d,
        .key_e,
        .key_f,
        .key_g,
        .key_h,
        .key_i,
        .key_j,
        .key_k,
        .key_l,
        .key_m,
        .key_n,
        .key_o,
        .key_p,
        .key_q,
        .key_r,
        .key_s,
        .key_t,
        .key_u,
        .key_v,
        .key_w,
        .key_x,
        .key_y,
        .key_z,
        => |raw| try fmt.allocPrintZ(allocator, "{s}", .{&[_]u8{@as(u8, @intCast(@intFromEnum(raw)))}}),
        .key_space => try fmt.allocPrintZ(allocator, "SPACE", .{}),
        .key_enter => try fmt.allocPrintZ(allocator, "ENTER", .{}),
        .key_tab => try fmt.allocPrintZ(allocator, "TAB", .{}),
        .key_backspace => try fmt.allocPrintZ(allocator, "BS", .{}),
        .key_insert => try fmt.allocPrintZ(allocator, "INS.", .{}),
        .key_delete => try fmt.allocPrintZ(allocator, "DEL.", .{}),
        .key_right => try fmt.allocPrintZ(allocator, "RIGHT", .{}),
        .key_left => try fmt.allocPrintZ(allocator, "LEFT", .{}),
        .key_down => try fmt.allocPrintZ(allocator, "DOWN", .{}),
        .key_up => try fmt.allocPrintZ(allocator, "UP", .{}),
        .key_page_up => try fmt.allocPrintZ(allocator, "PGUP", .{}),
        .key_page_down => try fmt.allocPrintZ(allocator, "PGDN", .{}),
        .key_home => try fmt.allocPrintZ(allocator, "HOME", .{}),
        .key_end => try fmt.allocPrintZ(allocator, "END", .{}),
        //.key_caps_lock => try fmt.allocPrintZ(allocator, "CA.LK", .{}),
        .key_f1 => try fmt.allocPrintZ(allocator, "F1", .{}),
        .key_f2 => try fmt.allocPrintZ(allocator, "F2", .{}),
        .key_f3 => try fmt.allocPrintZ(allocator, "F3", .{}),
        .key_f4 => try fmt.allocPrintZ(allocator, "F4", .{}),
        .key_f5 => try fmt.allocPrintZ(allocator, "F5", .{}),
        .key_f6 => try fmt.allocPrintZ(allocator, "F6", .{}),
        .key_f7 => try fmt.allocPrintZ(allocator, "F7", .{}),
        .key_f8 => try fmt.allocPrintZ(allocator, "F8", .{}),
        .key_f9 => try fmt.allocPrintZ(allocator, "F9", .{}),
        .key_f10 => try fmt.allocPrintZ(allocator, "F10", .{}),
        .key_f11 => try fmt.allocPrintZ(allocator, "F11", .{}),
        //.key_f12 => try fmt.allocPrintZ(allocator, "F12", .{}),
        .key_left_shift => try fmt.allocPrintZ(allocator, "L.SFT", .{}),
        .key_left_control => try fmt.allocPrintZ(allocator, "L.CTL", .{}),
        .key_left_alt => try fmt.allocPrintZ(allocator, "L.ALT", .{}),
        .key_right_shift => try fmt.allocPrintZ(allocator, "R.SFT", .{}),
        .key_right_control => try fmt.allocPrintZ(allocator, "R.CTL", .{}),
        .key_right_alt => try fmt.allocPrintZ(allocator, "R.ALT", .{}),
        else => unreachable,
    };
    //}}}
}

fn isSmallText(key: rl.KeyboardKey) bool {
    //{{{
    return switch (key) {
        .key_space,
        .key_enter,
        .key_tab,
        .key_insert,
        .key_delete,
        .key_right,
        .key_left,
        .key_down,
        .key_page_up,
        .key_page_down,
        .key_home,
        .key_end,
        //.key_caps_lock,
        .key_f10,
        .key_f11,
        //.key_f12,
        .key_left_shift,
        .key_left_control,
        .key_left_alt,
        .key_right_shift,
        .key_right_control,
        .key_right_alt,
        => true,
        else => false,
    };
    //}}}
}
