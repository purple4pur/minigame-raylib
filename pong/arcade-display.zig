const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");

pub const ArcadeDisplayError = error{
    CreateGridTwice,
    CreateDataTwice,
    GridNotCreate,
    DataNotCreate,
};

pub const ArcadeDisplay = struct {
    const Self = @This();

    allocator: mem.Allocator,
    x: i32,
    y: i32,
    numPxHorizontal: u32,
    numPxVertical: u32,
    pxSideLen: i32,

    grid: ?[][]rl.Rectangle = null,
    data: ?[][]rl.Color = null,

    pub fn init(allocator: mem.Allocator, x: i32, y: i32, numPxHorizontal: u32, numPxVertical: u32, pxSideLen: i32) Self {
        return Self{
            .allocator = allocator,
            .x = x,
            .y = y,
            .numPxHorizontal = numPxHorizontal,
            .numPxVertical = numPxVertical,
            .pxSideLen = pxSideLen,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.grid) |grid| {
            for (grid) |line| self.allocator.free(line);
            self.allocator.free(grid);
        }
        if (self.data) |data| {
            for (data) |line| self.allocator.free(line);
            self.allocator.free(data);
        }
        self.* = undefined;
    }

    pub fn create(self: *Self) !void {
        if (self.grid) |_| return ArcadeDisplayError.CreateGridTwice;
        if (self.data) |_| return ArcadeDisplayError.CreateDataTwice;

        self.grid = try self.allocator.alloc([]rl.Rectangle, self.numPxVertical);
        for (self.grid.?, 0..) |*line, i| {
            line.* = try self.allocator.alloc(rl.Rectangle, self.numPxHorizontal);
            for (line.*, 0..) |*px, j| {
                px.* = rl.Rectangle{
                    .x = @as(f32, @floatFromInt(self.pxSideLen * @as(i32, @intCast(j)))),
                    .y = @as(f32, @floatFromInt(self.pxSideLen * @as(i32, @intCast(i)))),
                    .width = @as(f32, @floatFromInt(self.pxSideLen)),
                    .height = @as(f32, @floatFromInt(self.pxSideLen)),
                };
            }
        }

        self.data = try self.allocator.alloc([]rl.Color, self.numPxVertical);
        for (self.data.?) |*line| {
            line.* = try self.allocator.alloc(rl.Color, self.numPxHorizontal);
            for (line.*) |*px| px.* = rl.Color.blank;
        }
    }

    pub fn draw(self: Self) !void {
        if (self.grid == null) return ArcadeDisplayError.GridNotCreate;
        if (self.data == null) return ArcadeDisplayError.DataNotCreate;

        for (self.grid.?, 0..) |line, i| {
            for (line, 0..) |px, j| {
                rl.drawRectangleRec(.{
                    .x = @as(f32, @floatFromInt(self.x)) + px.x,
                    .y = @as(f32, @floatFromInt(self.y)) + px.y,
                    .width = px.width,
                    .height = px.height,
                }, self.data.?[i][j]);
            }
        }
    }

    pub fn _debugOutline(self: Self) void {
        rl.drawRectangleLines(
            self.x,
            self.y,
            self.pxSideLen * @as(i32, @intCast(self.numPxHorizontal)),
            self.pxSideLen * @as(i32, @intCast(self.numPxVertical)),
            rl.Color.red,
        );
    }
};
