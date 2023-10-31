const std = @import("std");
const mem = std.mem;
const rl = @import("raylib");

pub const ArcadeDisplayError = error{
    DisplayCreateTwice,
    DisplayNotCreate,
};

pub fn Sprite(comptime width: comptime_int, comptime height: comptime_int) type {
    return [height][width]rl.Color;
}

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
        //{{{
        return Self{
            .allocator = allocator,
            .x = x,
            .y = y,
            .numPxHorizontal = numPxHorizontal,
            .numPxVertical = numPxVertical,
            .pxSideLen = pxSideLen,
        };
        //}}}
    }

    pub fn deinit(self: *Self) void {
        //{{{
        if (self.grid) |grid| {
            for (grid) |line| self.allocator.free(line);
            self.allocator.free(grid);
        }
        if (self.data) |data| {
            for (data) |line| self.allocator.free(line);
            self.allocator.free(data);
        }
        self.* = undefined;
        //}}}
    }

    pub fn create(self: *Self) !void {
        //{{{
        if (self.grid != null or self.data != null)
            return ArcadeDisplayError.DisplayCreateTwice;

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
        //}}}
    }

    pub fn clear(self: *Self) !void {
        //{{{
        if (self.grid == null or self.data == null)
            return ArcadeDisplayError.DisplayNotCreate;
        for (self.data.?) |*line| {
            for (line.*) |*px| px.* = rl.Color.blank;
        }
        //}}}
    }

    pub fn addDot(self: *Self, x: usize, y: usize, color: rl.Color) !void {
        //{{{
        if (self.grid == null or self.data == null)
            return ArcadeDisplayError.DisplayNotCreate;

        if (x < 0 or x >= self.numPxHorizontal) return;
        if (y < 0 or y >= self.numPxVertical) return;
        self.data.?[y][x] = color;
        //}}}
    }

    pub fn addRectangle(self: *Self, x: usize, y: usize, width: usize, height: usize, color: rl.Color) !void {
        //{{{
        if (self.grid == null or self.data == null)
            return ArcadeDisplayError.DisplayNotCreate;

        for (y..y + height + 1) |i| {
            if (i < 0 or i >= self.numPxVertical) continue;
            for (x..x + width + 1) |j| {
                if (j < 0 or j >= self.numPxHorizontal) continue;
                self.data.?[i][j] = color;
            }
        }
        //}}}
    }

    /// example: self.addSprite(Sprite(8, 5), 0, 0, sprite)
    /// example: self.addSprite(@TypeOf(sprite), 0, 0, sprite)
    pub fn addSprite(self: *Self, comptime T: type, x: usize, y: usize, sprite: T) !void {
        //{{{
        if (self.grid == null or self.data == null)
            return ArcadeDisplayError.DisplayNotCreate;

        const height = sprite.len;
        const width = if (height > 0) sprite[0].len else 0;
        for (y..y + height, 0..) |i, ii| {
            if (i < 0 or i >= self.numPxVertical) continue;
            for (x..x + width, 0..) |j, jj| {
                if (j < 0 or j >= self.numPxHorizontal) continue;
                self.data.?[i][j] = sprite[ii][jj];
            }
        }
        //}}}
    }

    pub fn draw(self: Self) !void {
        //{{{
        if (self.grid == null or self.data == null)
            return ArcadeDisplayError.DisplayNotCreate;

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
        //}}}
    }

    pub fn _debugOutline(self: Self) void {
        //{{{
        rl.drawRectangleLines(
            self.x,
            self.y,
            self.pxSideLen * @as(i32, @intCast(self.numPxHorizontal)),
            self.pxSideLen * @as(i32, @intCast(self.numPxVertical)),
            rl.Color.red,
        );
        //}}}
    }
};
