pub const Program = struct {
    name: []const u8,
    path: []const u8,
    desc: []const u8,
};

pub const programs = [_]Program{
    .{
        .name = "2048",
        .path = "2048/2048.zig",
        .desc = "The 2048 game",
    },
    .{
        .name = "pallete",
        .path = "pallete/pallete.zig",
        .desc = "Raylib buildin color pallete",
    },
    .{
        .name = "speedtest",
        .path = "speedtest/speedtest.zig",
        .desc = "",
    },
};

pub const tests = [_]Program{
    .{
        .name = "2048-test",
        .path = "2048/2048.zig",
        .desc = "Run 2048 test",
    },
};
