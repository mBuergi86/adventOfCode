const std = @import("std");

pub fn readFileToBuffer(file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const buffer = try file.readToEndAlloc(std.heap.page_allocator, 1024 * 1024);

    return buffer;
}
