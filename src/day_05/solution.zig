const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const lib = @import("lib");

pub const Error: type =
    std.fmt.ParseIntError ||
    std.Io.Writer.Error ||
    error{
        InvalidInput,
        OutOfMemory,
    };

test "partOne" {
    var output_buffer: [256]u8 = undefined;
    var output = std.Io.Writer.fixed(&output_buffer);
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    partOne(std.testing.allocator, input, &output) catch |err| {
        std.debug.print("Error: {s}\n", .{output.buffered()});
        return err;
    };
    try std.testing.expectEqualStrings("3", output.buffered());
}

pub const Range: type = struct {
    start: usize,
    end: usize,
    pub fn rangeLessThan(_: void, a: Range, b: Range) bool {
        if (a.start == b.start) return a.end < b.end;
        return a.start < b.start;
    }
};

pub fn partOne(allocator: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) !void {
    var result: u64 = 0;

    const fresh_id_ranges, const available_ids = try parseInput(allocator, input, output);
    defer allocator.free(fresh_id_ranges);
    defer allocator.free(available_ids);

    for (available_ids) |available_id| {
        const is_fresh = ret: {
            for (fresh_id_ranges) |fresh_range| {
                if (available_id >= fresh_range.start and available_id <= fresh_range.end) {
                    break :ret true;
                }
            }
            break :ret false;
        };

        if (is_fresh) result += 1;
    }

    _ = try output.print("{d}", .{result});
}

test "partTwo" {
    var output_buffer: [256]u8 = undefined;
    var output = std.io.Writer.fixed(&output_buffer);
    const input =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
    ;
    try partTwo(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("14", output.buffered());
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) !void {
    var result: u64 = 0;

    var combined_id_ranges: ArrayList(?Range) = .empty;
    defer combined_id_ranges.deinit(allocator);

    {
        const fresh_id_ranges, const available_ids = try parseInput(allocator, input, output);
        defer allocator.free(fresh_id_ranges);
        defer allocator.free(available_ids);

        std.sort.insertion(Range, fresh_id_ranges, {}, Range.rangeLessThan);

        for (fresh_id_ranges) |range| try combined_id_ranges.append(allocator, range);
    }

    main_loop: while (true) {
        var did_modify: bool = false;

        loop_left: for (combined_id_ranges.items[0..], 0..) |l_opt, l_idx| {
            var l = l_opt orelse continue :loop_left;
            loop_right: for (combined_id_ranges.items[l_idx + 1 ..], l_idx + 1..) |r_opt, r_idx| {
                const r = r_opt orelse continue :loop_right;
                if (l.end >= r.start) {
                    combined_id_ranges.items[r_idx] = null;
                    l = Range{ .start = l.start, .end = @max(l.end, r.end) };
                    combined_id_ranges.items[l_idx] = l;

                    did_modify = true;
                }
            }
        }

        if (!did_modify) break :main_loop;
    }

    for (combined_id_ranges.items) |range_opt| {
        const range = range_opt orelse continue;
        result += range.end - range.start + 1;
    }

    _ = try output.print("{d}", .{result});
}

pub fn main() !void {
    const input = @embedFile("./input.txt");

    try lib.runSolution("Part 1", input, partOne);
    try lib.runSolution("Part 2", input, partTwo);
}

pub fn parseInput(allocator: Allocator, input: []const u8, output: *std.Io.Writer) Error!struct { []Range, []usize } {
    var sections = std.mem.tokenizeSequence(u8, input, "\n\n");

    var fresh_ranges: ArrayList(Range) = .empty;
    errdefer fresh_ranges.deinit(allocator);

    const fresh_ranges_input = sections.next() orelse {
        try output.print("Missing fresh ranges", .{});
        return error.InvalidInput;
    };
    var fresh_ranges_iter = std.mem.tokenizeScalar(u8, fresh_ranges_input, '\n');

    var line: usize = 0;
    while (fresh_ranges_iter.next()) |range_input| {
        defer line += 1;

        var range_input_iter = std.mem.tokenizeAny(u8, range_input, "-");

        const start_input = range_input_iter.next() orelse {
            try output.print("Missing start at line {d}", .{line});
            return error.InvalidInput;
        };
        const start = try std.fmt.parseInt(usize, start_input, 10);

        const end_input = range_input_iter.next() orelse {
            try output.print("Missing end at line {d}", .{line});
            return error.InvalidInput;
        };
        const end = try std.fmt.parseInt(usize, end_input, 10);

        try fresh_ranges.append(allocator, Range{
            .start = start,
            .end = end,
        });
    }

    var available_ids: ArrayList(usize) = .empty;
    errdefer available_ids.deinit(allocator);

    const available_ids_input = sections.next() orelse {
        try output.print("Missing available ids", .{});
        return error.InvalidInput;
    };
    var available_ids_iter = std.mem.tokenizeScalar(u8, available_ids_input, '\n');
    while (available_ids_iter.next()) |available_id_input| {
        const available_id = try std.fmt.parseInt(usize, available_id_input, 10);
        try available_ids.append(allocator, available_id);
    }

    return .{
        try fresh_ranges.toOwnedSlice(allocator),
        try available_ids.toOwnedSlice(allocator),
    };
}
