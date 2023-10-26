const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");
const rlg = @import("raylib-group");
const Bar = @import("keyoverlay-bar.zig").Bar;
const Kps = @import("kps.zig").Kps;
const Chart = @import("chart.zig").Chart;
const Binding = union(enum) { keyboard: rl.KeyboardKey, mouse: rl.MouseButton };

const versionString = "0.1.0";
const homepageURL = "https://github.com/purple4pur/minigame-raylib/wiki/Homepage:-Speedtest";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const screenWidth = 450;
    const screenHeight = 420;
    rl.initWindow(screenWidth, screenHeight, "Speedtest " ++ versionString);
    defer rl.closeWindow();

    rl.setTargetFPS(360);

    var k1Binding = Binding{ .keyboard = rl.KeyboardKey.key_z };
    var k2Binding = Binding{ .keyboard = rl.KeyboardKey.key_x };

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

    var k1Text = rlg.DrawableObject{ .text = try bindingString(allocator, k1Binding) };
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

    var k2Text = rlg.DrawableObject{ .text = try bindingString(allocator, k2Binding) };
    defer allocator.free(k2Text.text);
    var k2TextProp = rlg.ObjectProperties{
        .x = 20 - @divFloor(rl.measureText(k2Text.text, 20), 2),
        .y = 11,
        .size = 20,
        .color = rl.Color.dark_gray,
    };
    try groupK2.add(&.{ .object = &k2Text, .properties = &k2TextProp });
    //}}}

    var k1Bar = Bar.init(allocator, 0, 15, 400, 30, rl.Color.gold);
    defer k1Bar.deinit();
    var k2Bar = Bar.init(allocator, 0, 65, 400, 30, rl.Color.gold);
    defer k2Bar.deinit();

    var kps = Kps.init(allocator, 4);
    defer kps.deinit();

    // groupKps
    // -------
    //{{{
    var groupKps = rlg.ObjectGroup.init(allocator, 250, 113);
    defer groupKps.deinit();

    try groupKps.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("KPS:")),
    }, .properties = &.{
        .x = 0,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var kpsText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(kpsText.text);
    try groupKps.add(&.{ .object = &kpsText, .properties = &.{
        .x = 55,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupKps.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("max:")),
    }, .properties = &.{
        .x = 100,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var kpsMaxText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(kpsMaxText.text);
    try groupKps.add(&.{ .object = &kpsMaxText, .properties = &.{
        .x = 150,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });
    //}}}

    // groupReset
    // ----------
    //{{{
    var groupReset = rlg.ObjectGroup.init(allocator, 17, 113);
    defer groupReset.deinit();

    const resetText = rlg.DrawableObject{ .text = @constCast("Reset") };
    const resetWidth = @as(f32, @floatFromInt(rl.measureText(resetText.text, 20)));
    var resetProp = rlg.ObjectProperties{
        .x = 0,
        .y = 0,
        .size = 20,
        .color = rl.Color.light_gray,
    };
    try groupReset.add(&.{ .object = &resetText, .properties = &resetProp });
    //}}}

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
        .text = @as([:0]u8, @constCast("BPM")),
    }, .properties = &.{
        .x = 70,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("now:")),
    }, .properties = &.{
        .x = 230,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var bpmNowText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(bpmNowText.text);
    try groupLegend.add(&.{ .object = &bpmNowText, .properties = &.{
        .x = 280,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("max:")),
    }, .properties = &.{
        .x = 330,
        .y = 0,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var bpmMaxText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(bpmMaxText.text);
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
        .text = @as([:0]u8, @constCast("Avg. BPM (2s)")),
    }, .properties = &.{
        .x = 70,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("now:")),
    }, .properties = &.{
        .x = 230,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm2sNowText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(avgBpm2sNowText.text);
    try groupLegend.add(&.{ .object = &avgBpm2sNowText, .properties = &.{
        .x = 280,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("max:")),
    }, .properties = &.{
        .x = 330,
        .y = 30,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm2sMaxText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(avgBpm2sMaxText.text);
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
        .text = @as([:0]u8, @constCast("Avg. BPM (5s)")),
    }, .properties = &.{
        .x = 70,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("now:")),
    }, .properties = &.{
        .x = 230,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm5sNowText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(avgBpm5sNowText.text);
    try groupLegend.add(&.{ .object = &avgBpm5sNowText, .properties = &.{
        .x = 280,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    try groupLegend.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("max:")),
    }, .properties = &.{
        .x = 330,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });

    var avgBpm5sMaxText = rlg.DrawableObject{ .text = try fmt.allocPrintZ(allocator, "0", .{}) };
    defer allocator.free(avgBpm5sMaxText.text);
    try groupLegend.add(&.{ .object = &avgBpm5sMaxText, .properties = &.{
        .x = 380,
        .y = 60,
        .size = 20,
        .color = rl.Color.dark_gray,
    } });
    //}}}

    // groupBinding
    // -----------
    //{{{
    var groupBinding = rlg.ObjectGroup.init(allocator, 0, 0);
    defer groupBinding.deinit();

    try groupBinding.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = screenWidth,
        .height = screenHeight,
    } }, .properties = &.{ .color = rl.Color.light_gray.fade(0.55) } });

    const promptK1 = "Press a key for K1 binding";
    const promptK2 = "Press a key for K2 binding";
    var bindingPrompt = rlg.DrawableObject{ .text = undefined };
    const promptWidthK1 = rl.measureText(promptK1, 20);
    const promptWidthK2 = rl.measureText(promptK2, 20);
    var promptBG = rlg.DrawableObject{ .rectangle = .{
        .x = undefined,
        .y = screenHeight / 2 - 20,
        .width = undefined,
        .height = 40,
    } };
    try groupBinding.add(&.{ .object = &promptBG, .properties = &.{ .color = rl.Color.dark_gray } });

    var promptProp = rlg.ObjectProperties{
        .x = undefined,
        .y = screenHeight / 2 - 10,
        .size = 20,
        .color = rl.Color.ray_white,
    };
    try groupBinding.add(&.{ .object = &bindingPrompt, .properties = &promptProp });
    //}}}

    // groupHelp
    // -----------
    //{{{
    var groupHelp = rlg.ObjectGroup.init(allocator, 0, 0);
    defer groupHelp.deinit();

    try groupHelp.add(&.{ .object = &.{ .rectangle = .{
        .x = 0,
        .y = 0,
        .width = screenWidth,
        .height = screenHeight,
    } }, .properties = &.{ .color = rl.Color.light_gray.fade(0.55) } });

    const groupHelpWidth = 380;
    const groupHelpHeight = 180;

    var helpMsgBG = rlg.DrawableObject{ .rectangle = .{
        .x = screenWidth / 2 - groupHelpWidth / 2,
        .y = screenHeight / 2 - groupHelpHeight / 2,
        .width = groupHelpWidth,
        .height = groupHelpHeight,
    } };
    try groupHelp.add(&.{ .object = &helpMsgBG, .properties = &.{ .color = rl.Color.dark_gray } });

    const helpMsg0 = rlg.DrawableObject{ .text = @constCast("(Click anywhere to return)") };
    const helpMsg1 = rlg.DrawableObject{ .text = @constCast("Hit the keys as fast and steady") };
    const helpMsg2 = rlg.DrawableObject{ .text = @constCast("as possible. Click on keycap") };
    const helpMsg3 = rlg.DrawableObject{ .text = @constCast("icons to change key bindings.") };

    try groupHelp.add(&.{ .object = &helpMsg0, .properties = &.{
        .x = screenWidth / 2 - groupHelpWidth / 2 + 20,
        .y = screenHeight / 2 - groupHelpHeight / 2 + 20,
        .size = 20,
        .color = rl.Color.ray_white,
    } });
    try groupHelp.add(&.{ .object = &helpMsg1, .properties = &.{
        .x = screenWidth / 2 - groupHelpWidth / 2 + 20,
        .y = screenHeight / 2 - groupHelpHeight / 2 + 70,
        .size = 20,
        .color = rl.Color.ray_white,
    } });
    try groupHelp.add(&.{ .object = &helpMsg2, .properties = &.{
        .x = screenWidth / 2 - groupHelpWidth / 2 + 20,
        .y = screenHeight / 2 - groupHelpHeight / 2 + 100,
        .size = 20,
        .color = rl.Color.ray_white,
    } });
    try groupHelp.add(&.{ .object = &helpMsg3, .properties = &.{
        .x = screenWidth / 2 - groupHelpWidth / 2 + 20,
        .y = screenHeight / 2 - groupHelpHeight / 2 + 130,
        .size = 20,
        .color = rl.Color.ray_white,
    } });
    //}}}

    // groupFooter
    // -----------
    //{{{
    var groupFooter = rlg.ObjectGroup.init(allocator, 18, 395);
    defer groupFooter.deinit();

    const helpButtonText = rlg.DrawableObject{ .text = @constCast("How to use?") };
    var helpButtonProp = rlg.ObjectProperties{
        .x = 0,
        .y = 0,
        .size = 10,
        .color = rl.Color.blue,
    };
    try groupFooter.add(&.{ .object = &helpButtonText, .properties = &helpButtonProp });

    const helpButtonWidth = @as(f32, @floatFromInt(rl.measureText(helpButtonText.text, 10)));
    var helpButtonUnderlineProp = rlg.ObjectProperties{ .color = rl.Color.blue };
    try groupFooter.add(&.{ .object = &.{ .rectangle = .{
        .x = @as(f32, @floatFromInt(helpButtonProp.x.?)),
        .y = @as(f32, @floatFromInt(helpButtonProp.y.? + 11)),
        .width = helpButtonWidth,
        .height = 1,
    } }, .properties = &helpButtonUnderlineProp });

    const homepageButtonText = rlg.DrawableObject{ .text = @constCast("Homepage") };
    var homepageButtonProp = rlg.ObjectProperties{
        .x = 75,
        .y = 0,
        .size = 10,
        .color = rl.Color.blue,
    };
    try groupFooter.add(&.{ .object = &homepageButtonText, .properties = &homepageButtonProp });

    const homepageButtonWidth = @as(f32, @floatFromInt(rl.measureText(homepageButtonText.text, 10)));
    var homepageButtonUnderlineProp = rlg.ObjectProperties{ .color = rl.Color.blue };
    try groupFooter.add(&.{ .object = &.{ .rectangle = .{
        .x = @as(f32, @floatFromInt(homepageButtonProp.x.?)),
        .y = @as(f32, @floatFromInt(homepageButtonProp.y.? + 11)),
        .width = homepageButtonWidth,
        .height = 1,
    } }, .properties = &homepageButtonUnderlineProp });

    try groupFooter.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("Made with")),
    }, .properties = &.{
        .x = 270,
        .y = 0,
        .size = 10,
        .color = rl.Color.dark_gray,
    } });

    try groupFooter.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("<3")),
    }, .properties = &.{
        .x = 323,
        .y = 0,
        .size = 10,
        .color = rl.Color.red,
    } });

    try groupFooter.add(&.{ .object = &.{
        .text = @as([:0]u8, @constCast("by @Purple4pur")),
    }, .properties = &.{
        .x = 337,
        .y = 0,
        .size = 10,
        .color = rl.Color.dark_gray,
    } });
    //}}}

    const Screen = enum { speedtest, k1_binding, k2_binding, help };
    var currentScreen: Screen = .speedtest;

    while (!rl.windowShouldClose()) {
        const time = rl.getTime();

        switch (currentScreen) {
            .speedtest => {
                //{{{
                if (isBindingDown(k1Binding)) {
                    k1BgProp.color = rl.Color.gold;
                    try k1Bar.pressed();
                } else {
                    k1BgProp.color = rl.Color.white;
                    try k1Bar.released();
                }

                if (isBindingDown(k2Binding)) {
                    k2BgProp.color = rl.Color.gold;
                    try k2Bar.pressed();
                } else {
                    k2BgProp.color = rl.Color.white;
                    try k2Bar.released();
                }

                if (isBindingPressed(k1Binding)) try kps.catchKeyAt(time);
                if (isBindingPressed(k2Binding)) try kps.catchKeyAt(time);

                // k1 button
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupK1.x)) + k1Rectangle.rectangle.x,
                    .y = @as(f32, @floatFromInt(groupK1.y)) + k1Rectangle.rectangle.y,
                    .width = k1Rectangle.rectangle.width,
                    .height = k1Rectangle.rectangle.height,
                })) {
                    k1BgProp.color = rl.Color.yellow;
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .k1_binding;
                    }
                }

                // k2 button
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupK2.x)) + k2Rectangle.rectangle.x,
                    .y = @as(f32, @floatFromInt(groupK2.y)) + k2Rectangle.rectangle.y,
                    .width = k2Rectangle.rectangle.width,
                    .height = k2Rectangle.rectangle.height,
                })) {
                    k2BgProp.color = rl.Color.yellow;
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .k2_binding;
                    }
                }

                // reset button
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupReset.x)) + 0,
                    .y = @as(f32, @floatFromInt(groupReset.y)) + 0,
                    .width = resetWidth,
                    .height = 20,
                })) {
                    resetProp.color = rl.Color.red;
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        kps.resetData();
                    }
                } else {
                    resetProp.color = rl.Color.light_gray;
                }

                // help button
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupFooter.x + helpButtonProp.x.?)),
                    .y = @as(f32, @floatFromInt(groupFooter.y + helpButtonProp.y.?)),
                    .width = helpButtonWidth,
                    .height = 12,
                })) {
                    helpButtonProp.color = rl.Color.dark_blue;
                    helpButtonUnderlineProp.color = rl.Color.dark_blue;
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .help;
                    }
                } else {
                    helpButtonProp.color = rl.Color.blue;
                    helpButtonUnderlineProp.color = rl.Color.blue;
                }

                // homepage button
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = @as(f32, @floatFromInt(groupFooter.x + homepageButtonProp.x.?)),
                    .y = @as(f32, @floatFromInt(groupFooter.y + homepageButtonProp.y.?)),
                    .width = homepageButtonWidth,
                    .height = 12,
                })) {
                    homepageButtonProp.color = rl.Color.dark_blue;
                    homepageButtonUnderlineProp.color = rl.Color.dark_blue;
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        rl.openURL(homepageURL);
                    }
                } else {
                    homepageButtonProp.color = rl.Color.blue;
                    homepageButtonUnderlineProp.color = rl.Color.blue;
                }
                //}}}
            },
            .k1_binding => {
                //{{{
                var bd: Binding = undefined;
                const mb = getMouseButtonPressedOrNull();
                if (mb) |m| {
                    bd = .{ .mouse = m };
                } else {
                    bd = .{ .keyboard = rl.getKeyPressed() };
                }

                if (isValidBinding(bd)) {
                    k1Binding = bd;
                    allocator.free(k1Text.text);
                    k1Text.text = try bindingString(allocator, bd);
                    if (needSmallText(bd)) {
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
                var bd: Binding = undefined;
                const mb = getMouseButtonPressedOrNull();
                if (mb) |m| {
                    bd = .{ .mouse = m };
                } else {
                    bd = .{ .keyboard = rl.getKeyPressed() };
                }

                if (isValidBinding(bd)) {
                    k2Binding = bd;
                    allocator.free(k2Text.text);
                    k2Text.text = try bindingString(allocator, bd);
                    if (needSmallText(bd)) {
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
            .help => {
                //{{{
                if (rl.checkCollisionPointRec(rl.getMousePosition(), .{
                    .x = 0,
                    .y = 0,
                    .width = screenWidth,
                    .height = screenHeight,
                })) {
                    if (rl.isMouseButtonReleased(rl.MouseButton.mouse_button_left)) {
                        currentScreen = .speedtest;
                    }
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

        allocator.free(kpsText.text);
        allocator.free(kpsMaxText.text);
        kpsText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.kps});
        kpsMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxKps});
        groupKps.drawAll();

        groupReset.drawAll();
        chart.draw();

        allocator.free(bpmNowText.text);
        allocator.free(bpmMaxText.text);
        allocator.free(avgBpm2sNowText.text);
        allocator.free(avgBpm2sMaxText.text);
        allocator.free(avgBpm5sNowText.text);
        allocator.free(avgBpm5sMaxText.text);
        bpmNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.bpm});
        bpmMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxBpm});
        avgBpm2sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm2s});
        avgBpm2sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm2s});
        avgBpm5sNowText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.avgBpm5s});
        avgBpm5sMaxText.text = try fmt.allocPrintZ(allocator, "{}", .{kps.maxAvgBpm5s});
        groupLegend.drawAll();

        groupFooter.drawAll();

        switch (currentScreen) {
            .k1_binding => {
                //{{{
                bindingPrompt.text = @constCast(promptK1);
                promptBG.rectangle.x = @as(f32, @floatFromInt(screenWidth / 2 - @divFloor(promptWidthK1, 2) - 15));
                promptBG.rectangle.width = @as(f32, @floatFromInt(promptWidthK1 + 30));
                promptProp.x = screenWidth / 2 - @divFloor(promptWidthK1, 2);
                groupBinding.drawAll();
                //}}}
            },
            .k2_binding => {
                //{{{
                bindingPrompt.text = @constCast(promptK2);
                promptBG.rectangle.x = @as(f32, @floatFromInt(screenWidth / 2 - @divFloor(promptWidthK2, 2) - 15));
                promptBG.rectangle.width = @as(f32, @floatFromInt(promptWidthK2 + 30));
                promptProp.x = screenWidth / 2 - @divFloor(promptWidthK2, 2);
                groupBinding.drawAll();
                //}}}
            },
            .help => groupHelp.drawAll(),
            else => {},
        }
    }
}

fn isBindingDown(binding: Binding) bool {
    //{{{
    return switch (binding) {
        .keyboard => |key| rl.isKeyDown(key),
        .mouse => |mouse| rl.isMouseButtonDown(mouse),
    };
    //}}}
}

fn isBindingPressed(binding: Binding) bool {
    //{{{
    return switch (binding) {
        .keyboard => |key| rl.isKeyPressed(key),
        .mouse => |mouse| rl.isMouseButtonPressed(mouse),
    };
    //}}}
}

fn getMouseButtonPressedOrNull() ?rl.MouseButton {
    //{{{
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) return rl.MouseButton.mouse_button_left;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_right)) return rl.MouseButton.mouse_button_right;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_middle)) return rl.MouseButton.mouse_button_middle;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_side)) return rl.MouseButton.mouse_button_side;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_extra)) return rl.MouseButton.mouse_button_extra;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_forward)) return rl.MouseButton.mouse_button_forward;
    if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_back)) return rl.MouseButton.mouse_button_back;
    return null;
    //}}}
}

fn isValidBinding(binding: Binding) bool {
    //{{{
    return switch (binding) {
        .keyboard => |key| switch (key) {
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
            .key_left_bracket,
            .key_backslash,
            .key_right_bracket,
            .key_grave,
            .key_kp_0,
            .key_kp_1,
            .key_kp_2,
            .key_kp_3,
            .key_kp_4,
            .key_kp_5,
            .key_kp_6,
            .key_kp_7,
            .key_kp_8,
            .key_kp_9,
            .key_kp_decimal,
            .key_kp_divide,
            .key_kp_multiply,
            .key_kp_subtract,
            .key_kp_add,
            .key_kp_enter,
            => true,
            else => false,
        },
        .mouse => |mb| switch (mb) {
            .mouse_button_left,
            .mouse_button_right,
            .mouse_button_middle,
            => true,
            else => false,
        },
    };
    //}}}
}

fn bindingString(allocator: mem.Allocator, binding: Binding) ![:0]u8 {
    //{{{
    return switch (binding) {
        .keyboard => |key| switch (key) {
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
            .key_left_bracket,
            .key_backslash,
            .key_right_bracket,
            .key_grave,
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
            .key_kp_0 => try fmt.allocPrintZ(allocator, "Num0", .{}),
            .key_kp_1 => try fmt.allocPrintZ(allocator, "Num1", .{}),
            .key_kp_2 => try fmt.allocPrintZ(allocator, "Num2", .{}),
            .key_kp_3 => try fmt.allocPrintZ(allocator, "Num3", .{}),
            .key_kp_4 => try fmt.allocPrintZ(allocator, "Num4", .{}),
            .key_kp_5 => try fmt.allocPrintZ(allocator, "Num5", .{}),
            .key_kp_6 => try fmt.allocPrintZ(allocator, "Num6", .{}),
            .key_kp_7 => try fmt.allocPrintZ(allocator, "Num7", .{}),
            .key_kp_8 => try fmt.allocPrintZ(allocator, "Num8", .{}),
            .key_kp_9 => try fmt.allocPrintZ(allocator, "Num9", .{}),
            .key_kp_decimal => try fmt.allocPrintZ(allocator, "Num.", .{}),
            .key_kp_divide => try fmt.allocPrintZ(allocator, "Num/", .{}),
            .key_kp_multiply => try fmt.allocPrintZ(allocator, "Num*", .{}),
            .key_kp_subtract => try fmt.allocPrintZ(allocator, "Num-", .{}),
            .key_kp_add => try fmt.allocPrintZ(allocator, "Num+", .{}),
            .key_kp_enter => try fmt.allocPrintZ(allocator, "NumE.", .{}),
            else => unreachable,
        },
        .mouse => |mb| switch (mb) {
            .mouse_button_left => try fmt.allocPrintZ(allocator, "MouL.", .{}),
            .mouse_button_right => try fmt.allocPrintZ(allocator, "MouR.", .{}),
            .mouse_button_middle => try fmt.allocPrintZ(allocator, "MouM.", .{}),
            else => unreachable,
        },
    };
    //}}}
}

fn needSmallText(binding: Binding) bool {
    //{{{
    return switch (binding) {
        .keyboard => |key| switch (key) {
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
            .key_kp_0,
            .key_kp_1,
            .key_kp_2,
            .key_kp_3,
            .key_kp_4,
            .key_kp_5,
            .key_kp_6,
            .key_kp_7,
            .key_kp_8,
            .key_kp_9,
            .key_kp_decimal,
            .key_kp_divide,
            .key_kp_multiply,
            .key_kp_subtract,
            .key_kp_add,
            .key_kp_enter,
            => true,
            else => false,
        },
        .mouse => true,
    };
    //}}}
}
