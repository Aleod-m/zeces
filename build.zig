const std = @import("std");

pub fn build(b: *std.Build) void {
    const build_options = b.addOptions();
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const erasure_checks = b.option(
        bool,
        "erasure-checks",
        "Enable type erasure checks.",
    ) orelse (optimize == .Debug);
    build_options.addOption(bool, "erasure_checks", erasure_checks);

    const lib_source: std.Build.StaticLibraryOptions = .{
        .name = "zeces",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    };
    const lib = b.addStaticLibrary(lib_source);
    lib.root_module.addOptions("build_options", build_options);
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.root_module.addOptions("build_options", build_options);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Check if the library and tests compile.
    const lib_check = b.addStaticLibrary(lib_source);
    const check = b.step("check", "Check if zeces compiles.");
    check.dependOn(&lib_check.step);
    check.dependOn(&lib_unit_tests.step);
}
