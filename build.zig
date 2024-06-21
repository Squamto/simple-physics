const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const math_module = b.dependency("math", .{}).module("math");

    const options: std.Build.StaticLibraryOptions = .{
        .name = "simple-physics",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    };

    const lib = b.addStaticLibrary(options);
    lib.root_module.addImport("math", math_module);
    b.installArtifact(lib);

    const module = b.addModule("simple-physics", .{
        .root_source_file = b.path("src/root.zig"),
    });
    module.addImport("math", math_module);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.root_module.addImport("math", math_module);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    const docs = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "docs",
        .source_dir = lib.getEmittedDocs(),
    });

    const doc_step = b.step("doc", "Install documentation");
    doc_step.dependOn(&docs.step);
}
