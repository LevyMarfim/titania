const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // === LIBRARY ===
    // Create the main library module
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Build as static library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "titania",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);

    // Also build as shared library for FFI (optional)
    const shared_lib = b.addSharedLibrary(.{
        .name = "titania",
        .root_module = lib_mod,
        .version = .{
            .major = 0,
            .minor = 1,
            .patch = 0,
        },
    });
    b.installArtifact(shared_lib);

    // === EXAMPLE EXECUTABLE ===
    // Build the example executable
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("titania", lib_mod);

    const exe = b.addExecutable(.{
        .name = "titania",
        .root_module = exe_mod,
    });
    b.installArtifact(exe);

    // === RUN STEP ===
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the example app");
    run_step.dependOn(&run_cmd.step);

    // === TESTS ===
    // Test the library
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_lib_tests.step);
}