const rl = @import("raylib");

pub const Chart = struct {
    const Self = @This();

    x: f32,
    y: f32,
    width: f32,
    height: f32,
    fontSize: f32,

    thickness: f32 = 2,
    h100: f32,
    h200: f32,

    pub fn init(x: f32, y: f32, width: f32, height: f32, fontSize: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .fontSize = fontSize,
            .h200 = height - fontSize - 2,
            .h100 = (height - fontSize - 2) / 2,
        };
    }

    pub fn drawChart(self: Self) void {
        // h100
        rl.drawLineEx(.{
            .x = self.x,
            .y = self.y + self.height - self.h100,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height - self.h100,
        }, self.thickness, rl.Color.light_gray);

        // h100 text
        rl.drawText(
            "100",
            @as(i32, @intFromFloat(self.x + 2)),
            @as(i32, @intFromFloat(self.y + self.height - self.h100 - self.fontSize - 2)),
            @as(i32, @intFromFloat(self.fontSize)),
            rl.Color.light_gray,
        );

        // h200
        rl.drawLineEx(.{
            .x = self.x,
            .y = self.y + self.height - self.h200,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height - self.h200,
        }, self.thickness, rl.Color.light_gray);

        // h200 text
        rl.drawText(
            "200",
            @as(i32, @intFromFloat(self.x + 2)),
            @as(i32, @intFromFloat(self.y + self.height - self.h200 - self.fontSize - 2)),
            @as(i32, @intFromFloat(self.fontSize)),
            rl.Color.light_gray,
        );

        // bottom (h0)
        rl.drawLineEx(.{
            .x = self.x,
            .y = self.y + self.height,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height,
        }, self.thickness, rl.Color.dark_gray);

        // h0 text
        rl.drawText(
            "0",
            @as(i32, @intFromFloat(self.x + 2)),
            @as(i32, @intFromFloat(self.y + self.height - self.fontSize - 2)),
            @as(i32, @intFromFloat(self.fontSize)),
            rl.Color.light_gray,
        );

        // right
        rl.drawLineEx(.{
            .x = self.x + self.width,
            .y = self.y,
        }, .{
            .x = self.x + self.width,
            .y = self.y + self.height + (self.thickness / 2),
        }, self.thickness, rl.Color.dark_gray);
    }

    pub fn _debugOutline(self: Self) void {
        rl.drawRectangleLines(
            @as(i32, @intFromFloat(self.x)),
            @as(i32, @intFromFloat(self.y)),
            @as(i32, @intFromFloat(self.width)),
            @as(i32, @intFromFloat(self.height)),
            rl.Color.red,
        );
    }
};
