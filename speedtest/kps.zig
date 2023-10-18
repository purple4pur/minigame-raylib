const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const rl = @import("raylib");

pub const Kps = struct {
    const TimeQueue = std.TailQueue(f64);

    const Self = @This();

    allocator: mem.Allocator,
    resolution: u16,
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

    pub fn init(allocator: mem.Allocator, resolution: u16, x: i32, y: i32, size: i32, color: rl.Color) Self {
        return Self{
            .allocator = allocator,
            .resolution = resolution,
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
            // store keystrokes within 3s, giving a wider range of valid resolution
            if (time - node.data < 3.0) break;
            self.bpmPool.remove(node);
            self.allocator.destroy(node);
        }

        self.refreshData();
    }

    fn refreshData(self: *Self) void {
        self.kps = @intCast(self.kpsPool.len);
        if (self.kps > self.maxKps) self.maxKps = self.kps;

        if (self.bpmPool.len <= self.resolution + 1) {
            // meaningless to calculate bpm
            self.bpm = 0;
        } else {
            // calculat bpm using the latest [resolution] keystrokes
            var it = self.bpmPool.last;
            const stampA = it.?.data;
            for (0..self.resolution) |_| it = it.?.prev;
            const stampB = it.?.data;

            const deltaTime = stampA - stampB;
            self.bpm = @as(u16, @intFromFloat(15.0 * @as(f64, @floatFromInt(self.resolution)) / deltaTime));

            if (self.bpm > self.maxBpm) self.maxBpm = self.bpm;
        }
    }

    pub fn drawKps(self: Self, buffer: []u8) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, "kps: {d}", .{self.kps}),
            self.x,
            self.y,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxKps(self: Self, buffer: []u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, "max: {d}", .{self.maxKps}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawBpm(self: Self, buffer: []u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, "bpm={d}", .{self.bpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }

    pub fn drawMaxBpm(self: Self, buffer: []u8, xShift: i32, yShift: i32) !void {
        rl.drawText(
            try fmt.bufPrintZ(buffer, "max: {d}", .{self.maxBpm}),
            self.x + xShift,
            self.y + yShift,
            self.size,
            self.color,
        );
    }
};
