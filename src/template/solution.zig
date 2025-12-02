const std = @import("std");
const lib = @import("lib");

test "partOne" {
    var output_buffer: [256]u8 = undefined;
    var output = std.Io.Writer.fixed(&output_buffer);
    errdefer std.debug.print("Error: {s}\n", .{output.buffered()});
    const input =
        \\123
        \\456
    ;
    try partOne(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("0", output.buffered());
}

pub fn partOne(allocator: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) !void {
    const result: i64 = 0;
    _ = allocator;
    _ = input;
    _ = try output.print("{d}", .{result});
}

test "partTwo" {
    var output_buffer: [256]u8 = undefined;
    var output = std.io.Writer.fixed(&output_buffer);
    errdefer std.debug.print("Error: {s}\n", .{output.buffered()});
    const input =
        \\123
        \\456
    ;
    try partTwo(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("0", output.buffered());
}

pub fn partTwo(allocator: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) !void {
    const result: i64 = 0;
    _ = allocator;
    _ = input;
    _ = try output.print("{d}", .{result});
}

pub fn main() !void {
    const input = @embedFile("./input.txt");

    try lib.runSolution("Part 1", input, partOne);
    try lib.runSolution("Part 2", input, partTwo);
}
