const std = @import("std");
const lib = @import("lib");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const Error: type =
    std.Io.Writer.Error ||
    std.fmt.ParseIntError ||
    std.mem.Allocator.Error ||
    error{
        InvalidInput,
    };

test "partOne" {
    var output_buffer: [256]u8 = undefined;
    var output = std.Io.Writer.fixed(&output_buffer);
    const input =
        \\123 328  51 64 
        \\45 64  387 23 
        \\6 98  215 314
        \\*   +   *   +  
    ;
    partOne(std.testing.allocator, input, &output) catch |err| {
        std.debug.print("Error: {s}\n", .{output.buffered()});
        return err;
    };
    try std.testing.expectEqualStrings("4277556", output.buffered());
}

pub fn partOne(allocator: Allocator, raw_input: []const u8, output: *std.Io.Writer) Error!void {
    var result: u64 = 0;

    const input = try parseInput(allocator, raw_input, output);
    defer allocator.free(input.data);
    defer allocator.free(input.operations);

    for (0..input.columns) |column_idx| {
        const row_count = @divExact(input.data.len, input.columns);
        const operation = input.operations[column_idx];
        var value: u64 = switch (operation) {
            .product => 1,
            .sum => 0,
        };
        for (0..row_count) |row_idx| {
            const item = std.fmt.parseInt(
                u64,
                input.data[row_idx * input.columns + column_idx],
                10,
            ) catch |err| {
                output.print("invalid int at row {d}, column {d}\n", .{ row_idx + 1, column_idx + 1 }) catch {};
                return err;
            };
            value = switch (operation) {
                .product => value * item,
                .sum => value + item,
            };
        }

        result += value;
    }

    try output.print("{d}", .{result});
}

test "partTwo" {
    var output_buffer: [256]u8 = undefined;
    var output = std.io.Writer.fixed(&output_buffer);
    const input = @embedFile("./sample_input.txt");
    partTwo(std.testing.allocator, input, &output) catch |err| {
        std.debug.print("Error: {s}\n", .{output.buffered()});
        return err;
    };
    try std.testing.expectEqualStrings("0", output.buffered());
}

pub fn partTwo(allocator: Allocator, input: []const u8, output: *std.Io.Writer) !void {
    const result: i64 = 0;
    try parsePartTwo(allocator, input, output);
    _ = try output.print("{d}", .{result});
}

pub fn main() !void {
    const input = @embedFile("./input.txt");

    try lib.runSolution("Part 1", input, partOne);
    try lib.runSolution("Part 2", input, partTwo);
}

const Operation: type = enum(u1) {
    product,
    sum,
};

const Input: type = struct {
    columns: usize,
    data: [][]const u8,
    operations: []Operation,
};

pub fn parseInput(allocator: Allocator, input: []const u8, output: *std.Io.Writer) Error!Input {
    var data: ArrayList([]const u8) = .empty;
    errdefer data.deinit(allocator);

    var operations: ArrayList(Operation) = .empty;
    errdefer data.deinit(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var columns: usize = 0;

    var line_idx: usize = 0;
    while (lines.next()) |line_bytes| : (line_idx += 1) {
        var line = std.mem.tokenizeScalar(u8, line_bytes, ' ');

        var column_idx: usize = 0;
        while (line.next()) |column_bytes| : (column_idx += 1) {
            try data.append(allocator, column_bytes);
            columns = @max(column_idx + 1, columns);
        }

        if (lines.peek()) |next_line_bytes| {
            if (std.mem.containsAtLeast(u8, next_line_bytes, 1, "*") or
                std.mem.containsAtLeast(u8, next_line_bytes, 1, "+"))
            {
                _ = line.next();
                var operators_iter = std.mem.tokenizeScalar(u8, next_line_bytes, ' ');
                while (operators_iter.next()) |operator_bytes| {
                    if (std.mem.eql(u8, operator_bytes, "*")) {
                        try operations.append(allocator, .product);
                        continue;
                    }
                    if (std.mem.eql(u8, operator_bytes, "+")) {
                        try operations.append(allocator, .sum);
                        continue;
                    }
                    output.print("Invalid Operation token found at column: {d}\n", .{operators_iter.index}) catch {};
                    return error.InvalidInput;
                }
                break;
            }
        }
    }

    std.debug.assert(columns == operations.items.len);
    std.debug.assert(0 == data.items.len % columns);
    std.debug.assert(line_idx + 1 == @divExact(data.items.len, columns));

    return Input{
        .columns = columns,
        .data = try data.toOwnedSlice(allocator),
        .operations = try operations.toOwnedSlice(allocator),
    };
}

fn parsePartTwo(allocator: Allocator, input: []const u8, output: *std.Io.Writer) Error!void {
    _ = allocator;

    var lines = std.mem.splitBackwardsScalar(u8, input, '\n');
    const last_line = lines.next() orelse {
        _ = output.write("last line missing") catch return error.InvalidInput;
        return error.InvalidInput;
    };

    std.debug.print("last line = {s}\n", .{last_line});
}
