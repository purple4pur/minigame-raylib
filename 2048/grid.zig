const std = @import("std");
const math = std.math;
const mem = std.mem;
const rand = std.rand;

const rl = @import("raylib");

const Direction = enum { up, down, left, right };
pub const GridError = error{ GridNotCreated, InvalidStarting };

pub const Grid = struct {
    const Self = @This();

    allocator: mem.Allocator = undefined,
    random: rand.Random = undefined,

    size: usize,
    width: i32,
    space: i32,
    margin: i32,

    starting: u16 = 2, // minimal value to start a game with
    grid: ?[][]rl.Rectangle = null,
    values: ?[][]u16 = null,

    const Pair = struct { x: usize, y: usize };

    pub fn init(
        allocator: mem.Allocator,
        random: rand.Random,
        gridSize: i32,
        brickWidth: i32,
        brickSpace: i32,
        brickMargin: i32,
    ) Self {
        //{{{
        return Self{
            .allocator = allocator,
            .random = random,
            .size = @as(usize, @intCast(gridSize)),
            .width = brickWidth,
            .space = brickSpace,
            .margin = brickMargin,
        };
        //}}}
    }

    pub fn getGrid(self: Self) ![]const []const rl.Rectangle {
        return if (self.grid) |g| g else GridError.GridNotCreated;
    }

    pub fn getValues(self: Self) ![]const []const u16 {
        return if (self.values) |v| v else GridError.GridNotCreated;
    }

    pub fn createGrid(self: *Self) !void {
        //{{{
        // initialize grid
        self.grid = try self.allocator.alloc([]rl.Rectangle, self.size);
        for (self.grid.?, 0..) |*line, row| {
            line.* = try self.allocator.alloc(rl.Rectangle, self.size);
            for (line.*, 0..) |*brick, col| {
                brick.* = rl.Rectangle.init(
                    f32FromInt(self.margin + (self.width + self.space) * @as(i32, @intCast(col))),
                    f32FromInt(self.margin + (self.width + self.space) * @as(i32, @intCast(row))),
                    f32FromInt(self.width),
                    f32FromInt(self.width),
                );
            }
        }

        // initialize values
        self.values = try self.allocator.alloc([]u16, self.size);
        for (self.values.?) |*line| {
            line.* = try self.allocator.alloc(u16, self.size);
            for (line.*) |*brick| {
                brick.* = 0;
            }
        }
        //}}}
    }

    pub fn deinit(self: *Self) void {
        //{{{
        if (self.grid) |grid| {
            for (grid) |line| {
                self.allocator.free(line);
            }
            self.allocator.free(grid);
        }

        if (self.values) |values| {
            for (values) |line| {
                self.allocator.free(line);
            }
            self.allocator.free(values);
        }

        self.* = undefined;
        //}}}
    }

    pub fn generate(self: *Self) !u128 {
        //{{{
        _ = try self.getGrid();
        if (self.starting == 0 or !math.isPowerOfTwo(self.starting)) return GridError.InvalidStarting;
        var max: u16 = 0;
        var min: u16 = math.maxInt(u16);

        // 1. collect all blank bricks
        var blanks = std.ArrayList(Pair).init(self.allocator);
        defer blanks.deinit();
        for (0..self.size) |line| {
            for (0..self.size) |i| {
                const v = self.values.?[line][i];
                if (v > 0) {
                    if (v > max) max = v;
                    if (v < min) min = v;
                    continue;
                }
                try blanks.append(.{ .x = line, .y = i });
            }
        }
        if (blanks.items.len == 0) return 0;

        // 2. generate candidate values
        var candidates = try self.allocator.alloc(u16, blanks.items.len);
        defer self.allocator.free(candidates);
        for (candidates) |*v| v.* = 0;

        // TODO: need better strategy
        candidates[0] = if (min != math.maxInt(u16)) min else self.starting;
        if (candidates.len >= 6) candidates[1] = if (min != math.maxInt(u16)) min * 2 else self.starting;
        if (candidates.len >= 9) candidates[2] = if (max > self.starting * 4) max / 2 else self.starting * 2;

        // 3. shuffle candidates
        self.random.shuffle(u16, candidates);

        // 4. set to blank bricks
        var newBrickFlag: u128 = 0;
        for (blanks.items, 0..) |blank, i| {
            self.values.?[blank.x][blank.y] = candidates[i];
            if (candidates[i] != 0) {
                // record new generated brick position
                newBrickFlag |= math.shl(u128, 1, blank.x * self.size + blank.y);
            }
        }

        return newBrickFlag;
        //}}}
    }

    pub fn move(self: *Self, d: Direction) !bool {
        //{{{
        _ = try self.getGrid();
        const beforePositionFlag = self.getPositionFlag();
        switch (d) {
            .left => {
                for (0..self.size) |line| {
                    var index: usize = 0;
                    var canStack = true;

                    for (0..self.size) |i| {
                        if (self.values.?[line][i] == 0) continue;
                        if (index > 0 and canStack and self.values.?[line][i] == self.values.?[line][index - 1]) {
                            self.values.?[line][index - 1] += self.values.?[line][i];
                            canStack = false;
                            continue;
                        }
                        self.values.?[line][index] = self.values.?[line][i];
                        index += 1;
                        canStack = true;
                    }
                    for (index..self.size) |i| self.values.?[line][i] = 0;
                }
            },
            .up => {
                for (0..self.size) |col| {
                    var index: usize = 0;
                    var canStack = true;

                    for (0..self.size) |i| {
                        if (self.values.?[i][col] == 0) continue;
                        if (index > 0 and canStack and self.values.?[i][col] == self.values.?[index - 1][col]) {
                            self.values.?[index - 1][col] += self.values.?[i][col];
                            canStack = false;
                            continue;
                        }
                        self.values.?[index][col] = self.values.?[i][col];
                        index += 1;
                        canStack = true;
                    }
                    for (index..self.size) |i| self.values.?[i][col] = 0;
                }
            },
            .right => {
                for (0..self.size) |line| {
                    var index: usize = 0;
                    var canStack = true;

                    for (0..self.size) |i| {
                        if (self.values.?[line][self.size - 1 - i] == 0) continue;
                        if (index > 0 and canStack and self.values.?[line][self.size - 1 - i] == self.values.?[line][self.size - index]) {
                            self.values.?[line][self.size - index] += self.values.?[line][self.size - 1 - i];
                            canStack = false;
                            continue;
                        }
                        self.values.?[line][self.size - 1 - index] = self.values.?[line][self.size - 1 - i];
                        index += 1;
                        canStack = true;
                    }
                    for (index..self.size) |i| self.values.?[line][self.size - 1 - i] = 0;
                }
            },
            .down => {
                for (0..self.size) |col| {
                    var index: usize = 0;
                    var canStack = true;

                    for (0..self.size) |i| {
                        if (self.values.?[self.size - 1 - i][col] == 0) continue;
                        if (index > 0 and canStack and self.values.?[self.size - 1 - i][col] == self.values.?[self.size - index][col]) {
                            self.values.?[self.size - index][col] += self.values.?[self.size - 1 - i][col];
                            canStack = false;
                            continue;
                        }
                        self.values.?[self.size - 1 - index][col] = self.values.?[self.size - 1 - i][col];
                        index += 1;
                        canStack = true;
                    }
                    for (index..self.size) |i| self.values.?[self.size - 1 - i][col] = 0;
                }
            },
        }
        const afterPositionFlag = self.getPositionFlag();
        return (beforePositionFlag != afterPositionFlag); // 'before != after' means a valid move
        //}}}
    }

    fn getPositionFlag(self: Self) u128 {
        //{{{
        var flag: u128 = 0;
        for (0..self.size) |i| {
            for (0..self.size) |j| {
                if (self.values.?[i][j] != 0) {
                    flag |= math.shl(u128, 1, i * self.size + j);
                }
            }
        }
        return flag;
        //}}}
    }
};

pub fn f32FromInt(int: anytype) f32 {
    return @as(f32, @floatFromInt(int));
}

pub fn i32FromFloat(float: anytype) i32 {
    return @as(i32, @intFromFloat(float));
}
