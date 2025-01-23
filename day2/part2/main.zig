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
        if (line.len == 0) continue;
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

    for (0..lists.items.len) |row_idx| {
        // print("Processing Row {d}\n", .{i + 1});

        var value_iter = mem.tokenize(u8, lists.items[row_idx], " ");
        var values_array = std.ArrayList(i32).init(alloc);
        defer values_array.deinit();

        while (value_iter.next()) |value| {
            const parsed = try std.fmt.parseInt(i32, value, 10);
            try values_array.append(parsed);
        }

        const values = values_array.items;

        if (isSafeRow(values)) {
            safe_count += 1;
            continue;
        }

        var made_safe = false;

        for (0..values.len) |remove_idx| {
            var tmp_arr = std.ArrayList(i32).init(alloc);
            defer tmp_arr.deinit();

            for (0..values.len) |i| {
                if (i == remove_idx) continue;
                try tmp_arr.append(values[i]);
            }

            const new_values = tmp_arr.items;

            if (isSafeRow(new_values)) {
                safe_count += 1;
                made_safe = true;
                break;
            }
        }
    }
    print("\nTotal Safe Row: {d}\n", .{safe_count});
}

fn isSafeRow(values: []const i32) bool {
    if (values.len < 2) {
        return true;
    }

    var direction: ?bool = null;

    for (1..values.len) |i| {
        const diff = values[i] - values[i - 1];

        if (diff == 0 or diff > 3 or diff < -3) {
            return false;
        }

        const current_dir = diff > 0;

        if (direction == null) {
            direction = current_dir;
        } else if (direction.? != current_dir) {
            return false;
        }
    }

    return true;
}
