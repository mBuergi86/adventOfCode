const std = @import("std");
const print = std.debug.print;
const readFileToBuffer = @import("readfile.zig").readFileToBuffer;
const mem = std.mem;

pub fn main() !void {
    const file_path = "items.txt";
    const readed_buf = try readFileToBuffer(file_path);

    if (readed_buf.len == 0) {
        print("Error: File is empty or unreeadable.\n", .{});
        return;
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    var lists = std.ArrayList([]const u8).init(alloc);
    defer lists.deinit();

    var line_iter = mem.tokenize(u8, readed_buf, "\n");

    while (line_iter.next()) |line| {
        try lists.append(line);
        // var col_iter = mem.tokenize(u8, line, " ");
        // while (col_iter.next()) |col| {
        //     const parsed = std.fmt.parseInt(i32, col, 10) catch |err| {
        //         print("Invalid number: {s}, {any}\n", .{ col, err });
        //         continue;
        //     };
        // }
    }

    var safe_count: u32 = 0;

    for (0..lists.items.len) |i| {
        // print("Processing Row {d}\n", .{i + 1});

        var value_iter = mem.tokenize(u8, lists.items[i], " ");
        var prev: ?i32 = null;
        var is_safe: bool = true;
        var direction: ?bool = null;

        while (value_iter.next()) |value| {
            const parsed = try std.fmt.parseInt(i32, value, 10);

            if (prev) |p| {
                const diff = parsed - p;

                if (diff > 3 or diff < -3 or diff == 0) {
                    is_safe = false;
                    break;
                }

                const current_dir = diff > 0;

                if (direction == null) {
                    direction = current_dir;
                } else {
                    if (direction.? != current_dir) {
                        is_safe = false;
                        break;
                    }
                }
            }
            prev = parsed;
        }

        if (is_safe) {
            safe_count += 1;
            // print("Safe\n", .{});
        }
        // else {
        //     print("Unsafe\n", .{});
        // }
    }
    print("\nTotal Safe Row: {d}\n", .{safe_count});
}
