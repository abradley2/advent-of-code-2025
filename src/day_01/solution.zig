const std = @import("std");
const lib = @import("lib");

const Error =
    std.fmt.ParseIntError || error{
        WriteFailed,
        InvalidDirection,
    };

test "partOne" {
    var output_buffer: [256]u8 = undefined;
    var output = std.Io.Writer.fixed(&output_buffer);
    const input =
        \\ L68
        \\ L30
        \\ R48
        \\ L5
        \\ R60
        \\ L55
        \\ L1
        \\ L99
        \\ R14
        \\ L82
    ;
    try partOne(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("3", output.buffered());
}

pub fn partOne(_: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) Error!void {
    var input_iter = std.mem.tokenizeAny(u8, input, " \n");

    var zeroes: u64 = 0;
    var dial: u64 = 50;
    while (input_iter.next()) |entry| {
        const dir = entry[0];
        var dist = try std.fmt.parseInt(u64, entry[1..], 10);

        if (dist == 0) continue;

        if (dir == 'L') {
            while (dist != 0) : (dist -= 1) {
                if (dial == 0) {
                    dial = 99;
                    continue;
                }
                dial -= 1;
            }
            if (dial == 0) zeroes += 1;
            continue;
        }

        if (dir == 'R') {
            while (dist != 0) : (dist -= 1) {
                if (dial == 99) {
                    dial = 0;
                    continue;
                }
                dial += 1;
            }
            if (dial == 0) zeroes += 1;
            continue;
        }

        return error.InvalidDirection;
    }

    _ = try output.print("{d}", .{zeroes});
}

test "partTwo" {
    var output_buffer: [256]u8 = undefined;
    var output = std.io.Writer.fixed(&output_buffer);
    const input =
        \\ L68
        \\ L30
        \\ R48
        \\ L5
        \\ R60
        \\ L55
        \\ L1
        \\ L99
        \\ R14
        \\ L82
    ;
    try partTwo(std.testing.allocator, input, &output);
    try std.testing.expectEqualStrings("6", output.buffered());
}

pub fn partTwo(_: std.mem.Allocator, input: []const u8, output: *std.Io.Writer) Error!void {
    var input_iter = std.mem.tokenizeAny(u8, input, " \n");

    var zeroes: u64 = 0;
    var dial: u64 = 50;
    while (input_iter.next()) |entry| {
        const dir = entry[0];
        var dist = try std.fmt.parseInt(u64, entry[1..], 10);

        if (dist == 0) continue;

        if (dir == 'L') {
            while (dist != 0) {
                dist -= 1;
                if (dial == 0) {
                    dial = 99;
                    continue;
                }
                dial -= 1;
                if (dial == 0) zeroes += 1;
            }
            continue;
        }

        if (dir == 'R') {
            while (dist != 0) {
                dist -= 1;
                if (dial == 99) {
                    dial = 0;
                    zeroes += 1;
                    continue;
                }
                dial += 1;
            }
            continue;
        }

        return error.InvalidDirection;
    }

    _ = try output.print("{d}", .{zeroes});
}

pub fn main() !void {
    const input = @embedFile("./input.txt");

    try lib.runSolution("Part 1", input, partOne);
    try lib.runSolution("Part 2", input, partTwo);
}
