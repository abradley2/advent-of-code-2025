const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;

const MAX_OUTPUT_BUFFER: usize = 1_024;

pub fn runSolution(
    name: []const u8,
    input: []const u8,
    solution: fn (
        allocator: Allocator,
        input: []const u8,
        output: *std.Io.Writer,
    ) anyerror!void,
) anyerror!void {
    var allocator = std.heap.smp_allocator;
    var debug_allocator: ?std.heap.DebugAllocator(.{}) = null;
    switch (builtin.mode) {
        .Debug => {
            debug_allocator = std.heap.DebugAllocator(.{}).init;
            allocator = debug_allocator.?.allocator();
        },
        else => {},
    }

    defer {
        if (debug_allocator) |*_debug_allocator| {
            _ = _debug_allocator.deinit();
        }
    }

    var output_buffer = std.mem.zeroes([MAX_OUTPUT_BUFFER]u8);
    var stdout_writer = std.fs.File.stdout().writer(&output_buffer);
    var writer: *std.io.Writer = &stdout_writer.interface;

    _ = try writer.write(name);
    _ = try writer.write(": ");
    try solution(allocator, input, &stdout_writer.interface);
    _ = try writer.write("\n");
    _ = try writer.flush();
}
