const std = @import("std");
const lib = @import("lib");

pub const Error: type =
    std.fmt.ParseIntError ||
    std.fmt.BufPrintError ||
    error{
        WriteFailed,
        ParserError,
    };

test "partOne" {
    var output_buffer: [256]u8 = undefined;
    var output = std.Io.Writer.fixed(&output_buffer);
    errdefer std.debug.print("Error: {s}", .{output.buffered()});
    const input =
        \\ 11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
        \\ 1698522-1698528,446443-446449,38593856-38593862,565653-565659,
        \\ 824824821-824824827,2121212118-2121212124
    ;
    try partOne(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("1227775554", output.buffered());
}

pub fn partOne(_: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) Error!void {
    var result: usize = 0;
    var entries_iter = std.mem.tokenizeAny(u8, input, " ,\n");
    var line: usize = 1;

    var id_buff: [256]u8 = undefined;

    while (entries_iter.next()) |entry| {
        defer line += 1;
        errdefer output.print("Error at line {d}", .{line}) catch {};

        var entry_iter = std.mem.tokenizeAny(u8, entry, " -");
        const start = entry_iter.next() orelse return error.ParserError;
        const end = entry_iter.next() orelse return error.ParserError;

        const start_id = try std.fmt.parseInt(usize, start[0..], 10);
        const end_id = try std.fmt.parseInt(usize, end[0..], 10);

        var current_id = start_id;
        while (current_id < end_id + 1) {
            defer current_id += 1;

            const id_ascii = try std.fmt.bufPrint(id_buff[0..], "{d}", .{current_id});
            if (id_ascii.len % 2 != 0) continue;

            const l = id_ascii[0..@divExact(id_ascii.len, 2)];
            const r = id_ascii[@divExact(id_ascii.len, 2)..];

            if (std.mem.eql(u8, l, r)) result += current_id;
        }
    }
    _ = try output.print("{d}", .{result});
}

test "partTwo" {
    var output_buffer: [256]u8 = undefined;
    var output = std.io.Writer.fixed(&output_buffer);
    errdefer std.debug.print("Error: {s}", .{output.buffered()});
    const input =
        \\ 11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
        \\ 1698522-1698528,446443-446449,38593856-38593862,565653-565659,
        \\ 824824821-824824827,2121212118-2121212124
    ;
    try partTwo(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("4174379265", output.buffered());
}

pub fn partTwo(_: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) Error!void {
    var result: usize = 0;
    var entries_iter = std.mem.tokenizeAny(u8, input, " ,\n");
    var line: usize = 1;

    var id_buff: [256]u8 = undefined;

    while (entries_iter.next()) |entry| {
        defer line += 1;
        errdefer output.print("Error at line {d}", .{line}) catch {};

        var entry_iter = std.mem.tokenizeAny(u8, entry, " -");
        const start = entry_iter.next() orelse return error.ParserError;
        const end = entry_iter.next() orelse return error.ParserError;

        const start_id = try std.fmt.parseInt(usize, start[0..], 10);
        const end_id = try std.fmt.parseInt(usize, end[0..], 10);

        var current_id = start_id;
        while (current_id < end_id + 1) {
            defer current_id += 1;

            var id_ascii = try std.fmt.bufPrint(id_buff[0..], "{d}", .{current_id});
            if (id_ascii.len == 1) continue;

            var current_len = @divTrunc(id_ascii.len, 2);
            entry_subsection: while (current_len > 0) : (current_len -= 1) {
                if (id_ascii.len % current_len != 0) {
                    continue;
                }

                const l = if (current_len == 1) id_ascii[0..1] else id_ascii[0..@divExact(id_ascii.len, current_len)];

                var r_start = l.len;
                var match: bool = true;

                std.debug.assert(r_start != id_ascii.len);
                while (r_start != id_ascii.len) : (r_start += l.len) {
                    const r = id_ascii[r_start .. r_start + l.len];
                    if (std.mem.eql(u8, l, r) == false) match = false;
                }

                if (match) {
                    result += current_id;
                    break :entry_subsection;
                }
            }
        }
    }
    _ = try output.print("{d}", .{result});
}

pub fn main() !void {
    const input = @embedFile("./input.txt");

    try lib.runSolution("Part 1", input, partOne);
    try lib.runSolution("Part 2", input, partTwo);
}
