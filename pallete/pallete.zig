const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    const screenWidth = 400;
    const screenHeight = 676; // 26*26

    rl.initWindow(screenWidth, screenHeight, "Raylib pallete");
    defer rl.closeWindow();

    rl.setTargetFPS(30);

    const ColorPair = struct { name: [:0]const u8, color: rl.Color };
    const pallete = [26]ColorPair{
        .{ .name = "light_gray", .color = rl.Color.light_gray },
        .{ .name = "gray", .color = rl.Color.gray },
        .{ .name = "dark_gray", .color = rl.Color.dark_gray },
        .{ .name = "yellow", .color = rl.Color.yellow },
        .{ .name = "gold", .color = rl.Color.gold },
        .{ .name = "orange", .color = rl.Color.orange },
        .{ .name = "pink", .color = rl.Color.pink },
        .{ .name = "red", .color = rl.Color.red },
        .{ .name = "maroon", .color = rl.Color.maroon },
        .{ .name = "green", .color = rl.Color.green },
        .{ .name = "lime", .color = rl.Color.lime },
        .{ .name = "dark_green", .color = rl.Color.dark_green },
        .{ .name = "sky_blue", .color = rl.Color.sky_blue },
        .{ .name = "blue", .color = rl.Color.blue },
        .{ .name = "dark_blue", .color = rl.Color.dark_blue },
        .{ .name = "purple", .color = rl.Color.purple },
        .{ .name = "violet", .color = rl.Color.violet },
        .{ .name = "dark_purple", .color = rl.Color.dark_purple },
        .{ .name = "beige", .color = rl.Color.beige },
        .{ .name = "brown", .color = rl.Color.brown },
        .{ .name = "dark_brown", .color = rl.Color.dark_brown },
        .{ .name = "white", .color = rl.Color.white },
        .{ .name = "black", .color = rl.Color.black },
        .{ .name = "blank", .color = rl.Color.blank },
        .{ .name = "magenta", .color = rl.Color.magenta },
        .{ .name = "ray_white", .color = rl.Color.ray_white },
    };

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        var i: i32 = 0;
        for (pallete) |color| {
            rl.drawRectangle(0, 26 * i, 200, 26, color.color);
            var textColor = color.color;
            if (std.mem.eql(u8, color.name, "white") or
                std.mem.eql(u8, color.name, "blank"))
            {
                textColor = rl.Color.light_gray;
            }
            rl.drawText(color.name, 220, 26 * i + 3, 20, textColor);
            i += 1;
        }
    }
}

fn f32FromInt(int: anytype) f32 {
    return @as(f32, @floatFromInt(int));
}
