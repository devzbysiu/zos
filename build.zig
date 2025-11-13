const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{ .cpu_arch = .riscv32, .os_tag = .freestanding, .abi = .none });
    const optimize = b.option(std.builtin.OptimizeMode, "optimize", "Optimize mode") orelse .ReleaseFast;

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "kernel",
        .root_module = root_mod,
    });

    exe.addAssemblyFile(b.path("src/trap_vector.S"));
    exe.setLinkerScript(b.path("kernel.ld"));

    const install = b.addInstallArtifact(exe, .{
        .dest_sub_path = "kernel.elf",
    });
    b.getInstallStep().dependOn(&install.step);
}
