const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");

pub const DrawableObject = union(enum) {
    rectangle: rl.Rectangle,
    text: [:0]u8,
};

pub const ObjectProperties = struct {
    x: ?i32 = null,
    y: ?i32 = null,
    size: ?i32 = null,
    color: ?rl.Color = null,
};

pub const rlObject = struct { object: *const DrawableObject, properties: *const ObjectProperties };

pub const ObjectGroup = struct {
    const Self = @This();

    x: i32,
    y: i32,
    components: std.ArrayList(*const rlObject),

    pub fn init(allocator: mem.Allocator, x: i32, y: i32) Self {
        return Self{
            .x = x,
            .y = y,
            .components = std.ArrayList(*const rlObject).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.components.deinit();
        self.* = undefined;
    }

    pub fn add(self: *Self, object: *const rlObject) !void {
        try self.components.append(object);
    }

    pub fn drawAll(self: Self) void {
        //{{{
        for (self.components.items) |comp| {
            switch (comp.object.*) {
                .rectangle => |rec| {
                    if (comp.properties.color == null) @panic(".color is not defined for rectangle");
                    rl.drawRectangleRec(.{
                        .x = @as(f32, @floatFromInt(self.x)) + rec.x,
                        .y = @as(f32, @floatFromInt(self.y)) + rec.y,
                        .width = rec.width,
                        .height = rec.height,
                    }, comp.properties.color.?);
                },
                .text => |text| {
                    if (comp.properties.x == null) @panic(".x is not defined for text");
                    if (comp.properties.y == null) @panic(".y is not defined for text");
                    if (comp.properties.size == null) @panic(".size is not defined for text");
                    if (comp.properties.color == null) @panic(".color is not defined for text");
                    rl.drawText(
                        text,
                        self.x + comp.properties.x.?,
                        self.y + comp.properties.y.?,
                        comp.properties.size.?,
                        comp.properties.color.?,
                    );
                },
            }
        }
        //}}}
    }
};
