const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");

pub const Kps = struct {
    const TimeQueue = std.TailQueue(f64);

    const Self = @This();

    allocator: mem.Allocator,
    numSample: u16,
    x: i32,
    y: i32,
    size: i32,
    color: rl.Color,

    kps: u16,
    maxKps: u16,
    kpsPool: TimeQueue,
    bpm: u16,
    maxBpm: u16,
    bpmPool: TimeQueue,

    pub fn init(allocator: mem.Allocator, numSample: u16, x: i32, y: i32, size: i32, color: rl.Color) Self {
        return Self{
            .allocator = allocator,
            .numSample = numSample,
            .x = x,
            .y = y,
            .size = size,
            .color = color,
            .kps = 0,
            .maxKps = 0,
            .kpsPool = TimeQueue{},
            .bpm = 0,
            .maxBpm = 0,
            .bpmPool = TimeQueue{},
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.kpsPool.first;
        var next: ?*TimeQueue.Node = null;
        while (it) |node| : (it = next) {
            next = node.next;
            self.allocator.destroy(node);
        }

        it = self.bpmPool.first;
        while (it) |node| : (it = next) {
            next = node.next;
            self.allocator.destroy(node);
        }

        self.* = undefined;
    }

    pub fn getKeyPressed(self: *Self, time: f64) !void {
        try self.addKpsStamp(time);
        try self.addBpmStamp(time);
        self.refreshData();
    }

    fn addKpsStamp(self: *Self, stamp: f64) !void {
        var nodePtr = try self.allocator.create(TimeQueue.Node);
        nodePtr.data = stamp;
        self.kpsPool.append(nodePtr);
    }

    fn addBpmStamp(self: *Self, stamp: f64) !void {
        var nodePtr = try self.allocator.create(TimeQueue.Node);
        nodePtr.data = stamp;
        self.bpmPool.append(nodePtr);
    }

    pub fn update(self: *Self, time: f64) void {
        var it = self.kpsPool.first;
        var next: ?*TimeQueue.Node = null;

        // update kpsPool
        while (it) |node| : (it = next) {
            next = node.next;

            // all stamps are within 1.0s, nothing to do
            if (time - node.data < 1.0) break;

            // this stamp is 1.0s earlier, remove it
            self.kpsPool.remove(node);
            self.allocator.destroy(node);
        }

        // update bpmPool
        it = self.bpmPool.first;
        while (it) |node| : (it = next) {
            next = node.next;
            // store keystrokes within 5s, giving a wider range of valid numSample
            if (time - node.data < 5.0) break;
            self.bpmPool.remove(node);
            self.allocator.destroy(node);
        }

        self.refreshData();
    }

    fn refreshData(self: *Self) void {
        self.kps = @intCast(self.kpsPool.len);
        if (self.kps > self.maxKps) self.maxKps = self.kps;

        // numSample needs +1 keystroke to get delta time
        if (self.bpmPool.len <= self.numSample + 1) {
            // meaningless to calculate bpm
            self.bpm = 0;
        } else {
            // calculat bpm using the latest [numSample] keystrokes
            var it = self.bpmPool.last;
            const stampA = it.?.data;
            for (0..self.numSample) |_| it = it.?.prev;
            const stampB = it.?.data;
            const deltaTime = stampA - stampB;

            // in an "osu!" bpm way:
            //   if you hit a key per 0.25s (avg of 4 hits in a second), you get a bpm of 60.
            // result in:
            //   bpm = (15 * numSample) / deltaTime
            self.bpm = @as(u16, @intFromFloat(15.0 * @as(f64, @floatFromInt(self.numSample)) / deltaTime));

            if (self.bpm > self.maxBpm) self.maxBpm = self.bpm;
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
