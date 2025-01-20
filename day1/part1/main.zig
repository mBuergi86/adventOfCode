const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("items.txt", .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const read_buf = try file.readToEndAlloc(alloc, 1024 * 1024);
    defer alloc.free(read_buf);

    var list1 = std.ArrayList(i32).init(alloc);
    defer list1.deinit();

    var list2 = std.ArrayList(i32).init(alloc);
    defer list2.deinit();

    var line_iter = std.mem.tokenize(u8, read_buf, "\n");
    while (line_iter.next()) |line| {
        // Zerlege jede Zeile in Spalten
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

    _ = std.mem.sort(i32, list1.items, {}, std.sort.asc(i32));
    _ = std.mem.sort(i32, list2.items, {}, std.sort.asc(i32));

    var result: u32 = 0;

    for (list1.items, 0..) |value, i| {
        result += @abs(value - list2.items[i]);
    }

    std.debug.print("Result: {d}\n", .{result});
}
