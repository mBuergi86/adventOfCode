const std = @import("std");
const print = std.debug.print;
const mem = std.mem;
const fmt = std.fmt;
const readFileToBuffer = @import("readfile.zig").readFileToBuffer;

pub fn main() !void {
    const file_path = "items.txt";
    const read_buffer = try readFileToBuffer(file_path);
    const start_valid_prefix = "mul(";
    const end_valid_prefix = ")";

    var sum: i32 = 0;
    var i: usize = 0;

    while (i < read_buffer.len) {
        if (mem.startsWith(u8, read_buffer[i..], start_valid_prefix)) {
            const start_idx = i + start_valid_prefix.len;
            const max_content_len: usize = 8;
            const end_slice = if (read_buffer.len - start_idx > max_content_len) start_idx + max_content_len else read_buffer.len;
            const short_slice = read_buffer[start_idx..end_slice];

            if (mem.indexOf(u8, short_slice, end_valid_prefix)) |end_idx| {
                const absolute_end_idx = start_idx + end_idx;
                const content = short_slice[0..end_idx];

                if (mem.indexOf(u8, content, ",")) |comma_idx| {
                    const left_str = content[0..comma_idx];
                    const right_str = content[comma_idx + 1 ..];

                    const left_val = try fmt.parseInt(i32, left_str, 10);
                    const right_val = try fmt.parseInt(i32, right_str, 10);

                    sum += left_val * right_val;
                }

                i = absolute_end_idx + 1;
            } else {
                i += start_valid_prefix.len;
            }
        } else {
            i += 1;
        }
    }

    print("Result: {d}\n", .{sum});
}
