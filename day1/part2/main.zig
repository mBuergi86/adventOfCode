const std = @import("std");
const readFileToBuffer = @import("readfile.zig").readFileToBuffer;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    const file_path = "items.txt";
    const read_buf = try readFileToBuffer(file_path, alloc);

    var list1 = std.ArrayList(i32).init(alloc);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(alloc);
    defer list2.deinit();

    var line_iter = std.mem.tokenize(u8, read_buf, "\n");
    while (line_iter.next()) |line| {
        var col_iter = std.mem.tokenize(u8, line, " ");
        var values: [2]i32 = undefined;
        var idx: usize = 0;

        while (col_iter.next()) |col| {
            values[idx] = try std.fmt.parseInt(i32, col, 10);
            idx += 1;
        }

        try list1.append(values[0]);
        try list2.append(values[1]);
    }

    var count_map = std.AutoHashMap(usize, i32).init(alloc);
    defer count_map.deinit();

    for (1..10) |key| {
        try count_map.put(key, 0);
    }

    for (list2.items) |value| {
        if (count_map.get(@intCast(value))) |count| {
            count_map.put(@intCast(value), count + 1) catch {};
        } else {
            try count_map.put(@intCast(value), 1);
        }
    }

    // var iteration = count_map.iterator();
    //
    // while (iteration.next()) |entry| {
    //     std.debug.print("Key: {d}, Value: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    // }

    var result: i32 = 0;

    for (list1.items) |value| {
        const count = count_map.get(@intCast(value)) orelse 0;
        result += value * count;
        // std.debug.print("Value: {d}, Count: {d}, Partial Result: {d}\n", .{ value, count, value * count });
    }

    std.debug.print("Result: {d}\n", .{result});
}
