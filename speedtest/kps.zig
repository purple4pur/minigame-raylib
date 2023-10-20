const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");

pub const Kps = struct {
    const TimeQueue = std.TailQueue(f64);

    const Self = @This();

    allocator: mem.Allocator,
    numSample: u16, // how many keystrokes calculating bpm is based on
    x: i32,
    y: i32,
    size: i32,
    color: rl.Color,

    keyPool: TimeQueue = TimeQueue{},
    kps: u16 = 0,
    maxKps: u16 = 0,
    bpm: u16 = 0,
    maxBpm: u16 = 0,

    pub fn init(allocator: mem.Allocator, numSample: u16, x: i32, y: i32, size: i32, color: rl.Color) Self {
        return Self{
            .allocator = allocator,
            .numSample = numSample,
            .x = x,
            .y = y,
            .size = size,
            .color = color,
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.keyPool.first;
        var next: ?*TimeQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;
            self.allocator.destroy(node);
        }
        self.* = undefined;
    }

    pub fn getKeyPressed(self: *Self, time: f64) !void {
        // append a timestamp to keyPool
        var nodePtr = try self.allocator.create(TimeQueue.Node);
        nodePtr.data = time;
        self.keyPool.append(nodePtr);
    }

    pub fn refreshData(self: *Self, currentTime: f64) void {
        // throw away old timestamps
        var it = self.keyPool.first;
        var next: ?*TimeQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;

            // throw away nodes that are 10.0s earlier
            if (currentTime - node.data < 10.0) break;
            self.keyPool.remove(node);
            self.allocator.destroy(node);
        }

        // update kps/bpm etc
        if (self.keyPool.len == 0) {
            self.kps = 0;
            self.bpm = 0;
        } else {
            var keyCountIn1s: u16 = 0;
            var keyCountIn1p8s: u16 = 0;
            var bpmStampA: f64 = 0;
            var bpmStampB: f64 = 0;

            it = self.keyPool.last;
            while (it) |node| : (it = node.prev) {
                if (currentTime - node.data < 1.0) keyCountIn1s += 1;
                if (currentTime - node.data < 1.8) keyCountIn1p8s += 1;

                if (keyCountIn1p8s == 1) bpmStampA = node.data;
                // bpm needs [numSample+1] keystrokes to get delta time
                if (keyCountIn1p8s == self.numSample + 1) bpmStampB = node.data;
            }

            self.kps = keyCountIn1s;
            if (self.kps > self.maxKps) self.maxKps = self.kps;

            if (bpmStampB == 0) {
                // not enough keystrokes to calculate bpm
                self.bpm = 0;
            } else {
                // in an "osu!" bpm way:
                //   if you hit a key per 0.25s (avg of 4 hits in a second), you get a bpm of 60.
                // result in:
                //   bpm = (15 * numSample) / deltaTime
                const deltaTime = bpmStampA - bpmStampB;
                self.bpm = @as(u16, @intFromFloat(15.0 * @as(f64, @floatFromInt(self.numSample)) / deltaTime));
                if (self.bpm > self.maxBpm) self.maxBpm = self.bpm;
            }
        }
    }

    pub fn drawKps(self: Self, buffer: []u8, comptime format: []const u8) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, format, .{self.kps}),
            self.x,
            self.y,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxKps(self: Self, buffer: []u8, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, format, .{self.maxKps}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawBpm(self: Self, buffer: []u8, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, format, .{self.bpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxBpm(self: Self, buffer: []u8, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, format, .{self.maxBpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }
};
