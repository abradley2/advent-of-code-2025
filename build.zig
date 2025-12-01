const std = @import("std");

pub const dayConfig: type = struct {
    name: []const u8,
    path: []const u8,
};

const day_configs: [13]dayConfig = [_]dayConfig{
    .{
        .name = "template",
        .path = "src/template/solution.zig",
    },
    .{
        .name = "day_01",
        .path = "src/day_01/solution.zig",
    },
    .{
        .name = "day_02",
        .path = "src/day_02/solution.zig",
    },
    .{
        .name = "day_03",
        .path = "src/day_03/solution.zig",
    },
    .{
        .name = "day_04",
        .path = "src/day_04/solution.zig",
    },
    .{
        .name = "day_05",
        .path = "src/day_05/solution.zig",
    },
    .{
        .name = "day_06",
        .path = "src/day_06/solution.zig",
    },
    .{
        .name = "day_07",
        .path = "src/day_07/solution.zig",
    },
    .{
        .name = "day_08",
        .path = "src/day_08/solution.zig",
    },
    .{
        .name = "day_09",
        .path = "src/day_09/solution.zig",
    },
    .{
        .name = "day_10",
        .path = "src/day_10/solution.zig",
    },
    .{
        .name = "day_11",
        .path = "src/day_11/solution.zig",
    },
    .{
        .name = "day_12",
        .path = "src/day_12/solution.zig",
    },
};

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib_mod = b.addModule("advent_of_code", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
    });

    for (day_configs) |day_config| {
        const exe = b.addExecutable(.{
            .name = day_config.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(day_config.path),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "lib", .module = lib_mod },
                },
            }),
        });

        b.installArtifact(exe);

        const run_step = b.step(day_config.name, "Run specified day");

        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);

        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const exe_tests = b.addTest(.{
            .root_module = exe.root_module,
        });

        const run_exe_tests = b.addRunArtifact(exe_tests);

        const test_step_name: []u8 = test_step_name: {
            var test_step_name: std.ArrayList(u8) = .empty;
            try test_step_name.appendSlice(b.allocator, day_config.name);
            try test_step_name.appendSlice(b.allocator, "_test");
            break :test_step_name test_step_name.items;
        };

        const test_step = b.step(test_step_name, "Run tests for specified day");
        test_step.dependOn(&run_exe_tests.step);
    }
}
