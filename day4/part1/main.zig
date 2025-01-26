const std = @import("std");
const print = std.debug.print;
const mem = std.mem;

pub fn main() !void {
    const file_path = "items.txt";
    const read_buffer = try readFileToBuffer(file_path);
    const xmas = "XMAS";

    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();

    var line_iter = mem.tokenize(u8, read_buffer, "\n");
    while (line_iter.next()) |line| {
        try lines.append(line);
    }

    const rows = lines.items.len;
    if (rows == 0) {
        print("Result: 0\n", .{});
        return;
    }
    const cols = lines.items[0].len;

    var count: usize = 0;

    const directions = [_][2]i32{
        .{ 0, 1 }, // right
        .{ 0, -1 }, // left
        .{ 1, 0 }, // down
        .{ -1, 0 }, // up
        .{ 1, 1 }, // down-right
        .{ 1, -1 }, // up-right
        .{ -1, 1 }, // down-left
        .{ -1, -1 }, // up-left
    };

    for (lines.items, 0..) |line, i| {
        for (0..line.len) |j| {
            if (line[j] != 'X') continue;

            dir_loop: for (directions) |dir| {
                const dx = dir[0];
                const dy = dir[1];

                const new_i = @as(i32, @intCast(i)) + 3 * dx;
                const new_j = @as(i32, @intCast(j)) + 3 * dy;

                if (new_i < 0 or new_i >= rows) continue :dir_loop;
                if (new_j < 0 or new_j >= cols) continue :dir_loop;

                for (0..4) |k| {
                    const current_i = @as(i32, @intCast(i)) + dx * @as(i32, @intCast(k));
                    const current_j = @as(i32, @intCast(j)) + dy * @as(i32, @intCast(k));

                    const row = @as(usize, @intCast(current_i));
                    const col = @as(usize, @intCast(current_j));

                    if (lines.items[row][col] != xmas[k]) continue :dir_loop;
                }

                count += 1;
            }
        }
    }

    print("Result: {d}\n", .{count});
}

fn readFileToBuffer(file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const buffer = try std.heap.page_allocator.alloc(u8, file_size);
    _ = try file.readAll(buffer);
    return buffer;
}
