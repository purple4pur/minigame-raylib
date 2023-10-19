const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");

const Status = enum { released, pressed };
const StartEndPair = struct { start: f32, end: f32 };
const BarQueue = std.TailQueue(StartEndPair);

pub const Bar = struct {
    const Self = @This();

    allocator: mem.Allocator,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    color: rl.Color,

    bars: BarQueue = BarQueue{},
    status: Status = .released,

    pub fn init(allocator: mem.Allocator, x: i32, y: i32, width: i32, height: i32, color: rl.Color) Self {
        return Self{
            .allocator = allocator,
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .color = color,
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.bars.first;
        var next: ?*BarQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;
            self.allocator.destroy(node);
        }
        self.* = undefined;
    }

    pub fn draw(self: Self) void {
        var it = self.bars.first;
        while (it) |node| : (it = node.next) {
            rl.drawRectangle(
                // drawing from right to left:
                // |end <---- start|
                self.x + self.width - @as(i32, @intFromFloat(node.data.end)), // x
                self.y, // y
                @as(i32, @intFromFloat(node.data.end - node.data.start)), // width
                self.height, // height
                self.color,
            );
        }
    }

    pub fn pressed(self: *Self) !void {
        switch (self.status) {
            .pressed => {
                // nothing to do
            },
            .released => {
                try self.add(.{ .start = -1, .end = 0 });
                self.status = .pressed;
            },
        }
    }

    pub fn released(self: *Self) !void {
        switch (self.status) {
            .released => {
                // nothing to do
            },
            .pressed => {
                if (self.bars.last) |last| {
                    last.data.start = 0;
                } else {
                    @panic("try to release when there's no active bar");
                }
                self.status = .released;
            },
        }
    }

    pub fn update(self: *Self, speed: f32) void {
        const pixelSpeed: f32 = speed * 240.0 / @as(f32, @floatFromInt(rl.getFPS()));

        var it = self.bars.first;
        var next: ?*BarQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;
            const startOverflow = node.data.start > @as(f32, @floatFromInt(self.width));
            const endOverflow = node.data.end > @as(f32, @floatFromInt(self.width));
            const startUnderflow = node.data.start < 0;

            if (startOverflow) {
                // start and end are both out of bounds, remove this node
                self.bars.remove(node);
                self.allocator.destroy(node);
            } else {
                // update position
                if (!startUnderflow) node.data.start += pixelSpeed; // underflow means it's being pressed
                if (!endOverflow) node.data.end += pixelSpeed;
            }
        }
    }

    fn add(self: *Self, pair: StartEndPair) !void {
        var nodePtr = try self.allocator.create(BarQueue.Node);
        nodePtr.data = .{ .start = pair.start, .end = pair.end };
        self.bars.append(nodePtr);
    }

    pub fn _debugOutline(self: Self) void {
        rl.drawRectangleLines(self.x, self.y, self.width, self.height, rl.Color.red);
    }
};
