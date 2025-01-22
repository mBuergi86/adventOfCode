const std = @import("std");

pub fn readFileToBuffer(file_path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buffer = try file.readToEndAlloc(allocator, 1024 * 1024);
    return buffer;
}
