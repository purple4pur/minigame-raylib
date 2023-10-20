const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");

pub const Chart = struct {
    const Line = struct { from: rl.Vector2, to: rl.Vector2 };
    const LineQueue = std.TailQueue(Line);

    const Self = @This();

    allocator: mem.Allocator,
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    fontSize: f32,
    h200: f32,
    h100: f32,

    thickness: f32 = 2,
    lines: LineQueue = LineQueue{},
    bpms: [8]f32 = mem.zeroes([8]f32),

    const bpmWeights = [8]f32{ 0.09, 0.16, 0.25, 0.36, 0.49, 0.64, 0.81, 1 };
    const bpmWeightTotal = t: {
        var total: f32 = 0;
        for (bpmWeights) |w| total += w;
        break :t total;
    };

    pub fn init(allocator: mem.Allocator, x: f32, y: f32, width: f32, height: f32, fontSize: f32) Self {
        return Self{
            .allocator = allocator,
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .fontSize = fontSize,
            .h200 = height - fontSize - 2,
            .h100 = (height - fontSize - 2) / 2,
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.lines.first;
        var next: ?*LineQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;
            self.allocator.destroy(node);
        }
        self.* = undefined;
    }

    pub fn receiveBpm(self: *Self, bpm: u16) !void {
        const hBpm = @as(f32, @floatFromInt(bpm)) * self.h200 / 200;

        for (0..7) |i| self.bpms[i] = self.bpms[i + 1];
        self.bpms[7] = hBpm;

        var nodePtr = try self.allocator.create(LineQueue.Node);
        nodePtr.data = .{
            .from = .{
                .x = 0,
                .y = if (self.lines.last) |last| last.data.to.y else 0,
            },
            .to = .{
                .x = -1, // -1 marks a new line
                .y = t: {
                    var y: f32 = 0;
                    for (self.bpms, bpmWeights) |b, w| {
                        y += b * w;
                    }
                    y /= bpmWeightTotal;
                    break :t y;
                },
            },
        };
        self.lines.append(nodePtr);
    }

    pub fn update(self: *Self, speed: f32) void {
        const pixelSpeed: f32 = speed * 240.0 / @as(f32, @floatFromInt(rl.getFPS()));

        var it = self.lines.first;
        var next: ?*LineQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;

            node.data.from.x += pixelSpeed;
            if (node.data.to.x == -1) {
                // a new line
                node.data.to.x = 0;
            } else {
                node.data.to.x += pixelSpeed;
            }

            if (node.data.to.x > self.width) {
                // this line is out of bounds
                self.lines.remove(node);
                self.allocator.destroy(node);
            }
        }
    }

    pub fn draw(self: Self) void {
        self.drawGrid();
        self.drawBpm();
    }

    fn drawGrid(self: Self) void {
        //{{{
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
            .y = self.y + self.height + (self.thickness / 2), // fill the bottom-right blank
        }, self.thickness, rl.Color.dark_gray);
        //}}}
    }

    fn drawBpm(self: Self) void {
        var it = self.lines.first;
        while (it) |node| : (it = node.next) {
            rl.drawLineEx(.{
                .x = self.x + self.width - node.data.from.x,
                .y = self.y + self.height - node.data.from.y,
            }, .{
                .x = self.x + self.width - node.data.to.x,
                .y = self.y + self.height - node.data.to.y,
            }, self.thickness + 1, rl.Color.yellow);
        }
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
