const std = @import("std");
const print = std.debug.print;
const mem = std.mem;

pub fn main() !void {
    const file_path = "items.txt";
    const read_buffer = try readFileToBuffer(file_path);

    var lines = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer lines.deinit();

    var line_iter = mem.tokenize(u8, read_buffer, "\n");
    while (line_iter.next()) |line| {
        try lines.append(line);
    }

    const rows = lines.items.len;
    if (rows < 3) {
        print("Result: 0\n", .{});
        return;
    }
    const cols = lines.items[0].len;
    if (cols < 3) {
        print("Result: 0\n", .{});
        return;
    }

    var count: usize = 0;

    for (1..rows - 1) |i| {
        for (1..cols - 1) |j| {
            // Check first diagonal (top-left to bottom-right)
            const diag1 = [3]u8{
                lines.items[i - 1][j - 1],
                lines.items[i][j],
                lines.items[i + 1][j + 1],
            };
            const valid_diag1 = mem.eql(u8, &diag1, "MAS") or mem.eql(u8, &diag1, "SAM");

            // Check second diagonal (top-right to bottom-left)
            const diag2 = [3]u8{
                lines.items[i - 1][j + 1],
                lines.items[i][j],
                lines.items[i + 1][j - 1],
            };
            const valid_diag2 = mem.eql(u8, &diag2, "MAS") or mem.eql(u8, &diag2, "SAM");

            if (valid_diag1 and valid_diag2) {
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
