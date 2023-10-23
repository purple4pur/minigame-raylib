const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");

pub const Kps = struct {
    const TimeQueue = std.TailQueue(f64);
    const BpmQueue = std.TailQueue(struct { bpm: u16, time: f64 });

    const Self = @This();

    allocator: mem.Allocator,
    x: i32,
    y: i32,
    size: i32,
    color: rl.Color,
    numSample: u16, // how many keystrokes calculating bpm is based on

    keyPool: TimeQueue = TimeQueue{},
    bpmPool: BpmQueue = BpmQueue{},
    kps: u16 = 0,
    maxKps: u16 = 0,
    bpm: u16 = 0,
    maxBpm: u16 = 0,
    avgBpm2s: u16 = 0,
    maxAvgBpm2s: u16 = 0,
    avgBpm5s: u16 = 0,
    maxAvgBpm5s: u16 = 0,

    pub fn init(allocator: mem.Allocator, x: i32, y: i32, size: i32, color: rl.Color, numSample: u16) Self {
        return Self{
            .allocator = allocator,
            .x = x,
            .y = y,
            .size = size,
            .color = color,
            .numSample = numSample,
        };
    }

    pub fn deinit(self: *Self) void {
        {
            var it = self.keyPool.first;
            var next: ?*TimeQueue.Node = null;
            while (it) |node| : (it = next) {
                next = node.next;
                self.allocator.destroy(node);
            }
        }
        {
            var it = self.bpmPool.first;
            var next: ?*BpmQueue.Node = null;
            while (it) |node| : (it = next) {
                next = node.next;
                self.allocator.destroy(node);
            }
        }
        self.* = undefined;
    }

    pub fn catchKeyAt(self: *Self, time: f64) !void {
        // append a timestamp to keyPool
        var nodePtr = try self.allocator.create(TimeQueue.Node);
        nodePtr.data = time;
        self.keyPool.append(nodePtr);
    }

    pub fn refreshData(self: *Self, currentTime: f64) !void {
        {
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
        }

        // update kps/bpm etc
        if (self.keyPool.len == 0) {
            self.kps = 0;
            self.bpm = 0;
        } else {
            var keyCountIn1s: u16 = 0;
            var keyCountIn1p8s: u16 = 0;
            var timeA: f64 = 0;
            var timeB: f64 = 0;

            var it = self.keyPool.last;
            while (it) |node| : (it = node.prev) {
                if (currentTime - node.data < 1.0) keyCountIn1s += 1;
                if (currentTime - node.data < 1.8) keyCountIn1p8s += 1;

                if (keyCountIn1p8s == 1) timeA = node.data;
                // bpm needs [numSample+1] keystrokes to get delta time
                if (keyCountIn1p8s == self.numSample + 1) timeB = node.data;
            }

            self.kps = keyCountIn1s;
            if (self.kps > self.maxKps) self.maxKps = self.kps;

            if (timeB == 0) {
                // not enough keystrokes to calculate bpm
                self.bpm = 0;
            } else {
                // in an "osu!" bpm way:
                //   if you hit a key per 0.25s (avg of 4 hits in a second), you get a bpm of 60.
                // result in:
                //   bpm = (15 * numSample) / deltaTime
                const deltaTime = timeA - timeB;
                self.bpm = @as(u16, @intFromFloat(15.0 * @as(f64, @floatFromInt(self.numSample)) / deltaTime));
                if (self.bpm > self.maxBpm) self.maxBpm = self.bpm;
            }
        }

        {
            // append current bpm to bpmPool
            var nodePtr = try self.allocator.create(BpmQueue.Node);
            nodePtr.data = .{ .bpm = self.bpm, .time = currentTime };
            self.bpmPool.append(nodePtr);

            var it = self.bpmPool.first;
            var next: ?*BpmQueue.Node = null;
            var bpmCountIn2s: u16 = 0;
            var totalBpm2s: f32 = 0;
            var totalBpm5s: f32 = 0;
            while (it) |node| : (it = next) {
                next = node.next;
                if (currentTime - node.data.time >= 5.0) {
                    // throw away nodes 5s earlier
                    self.bpmPool.remove(node);
                    self.allocator.destroy(node);
                    continue;
                }
                if (currentTime - node.data.time < 2.0) {
                    totalBpm2s += @as(f32, @floatFromInt(node.data.bpm));
                    bpmCountIn2s += 1;
                }
                totalBpm5s += @as(f32, @floatFromInt(node.data.bpm));
            }

            // calculate average bpm
            self.avgBpm2s = @as(u16, @intFromFloat(totalBpm2s / @as(f32, @floatFromInt(bpmCountIn2s))));
            if (self.avgBpm2s > self.maxAvgBpm2s) self.maxAvgBpm2s = self.avgBpm2s;
            self.avgBpm5s = @as(u16, @intFromFloat(totalBpm5s / @as(f32, @floatFromInt(self.bpmPool.len))));
            if (self.avgBpm5s > self.maxAvgBpm5s) self.maxAvgBpm5s = self.avgBpm5s;
        }
    }

    pub fn drawKps(self: Self, comptime format: []const u8) !void {
        rl.drawText(
            try fmt.allocPrintZ(self.allocator, format, .{self.kps}),
            self.x,
            self.y,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxKps(self: Self, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.allocPrintZ(self.allocator, format, .{self.maxKps}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawBpm(self: Self, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.allocPrintZ(self.allocator, format, .{self.bpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxBpm(self: Self, comptime format: []const u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.allocPrintZ(self.allocator, format, .{self.maxBpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }
};
