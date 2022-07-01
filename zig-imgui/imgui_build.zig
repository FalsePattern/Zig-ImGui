const std = @import("std");

// @src() is only allowed inside of a function, so we need this wrapper
fn srcFile() []const u8 { return @src().file; }
const sep = std.fs.path.sep_str;

const zig_imgui_path = std.fs.path.dirname(srcFile()).?;
pub const pkg = std.build.Pkg{
    .name = "imgui",
    .source = .{ .path = zig_imgui_path ++ sep ++ "imgui.zig" },
};

pub fn link(exe: *std.build.LibExeObjStep) void {
    linkWithoutPackage(exe);
    exe.addPackage(pkg);
}

pub fn linkWithoutPackage(exe: *std.build.LibExeObjStep) void {
    const imgui_cpp_file = zig_imgui_path ++ sep ++ "cimgui_unity.cpp";

    exe.linkLibCpp();
    exe.addCSourceFile(imgui_cpp_file, &[_][]const u8 {
        "-fno-sanitize=undefined",
        "-ffunction-sections",
    });
}

pub fn addTestStep(
    b: *std.build.Builder,
    step_name: []const u8,
    mode: std.builtin.Mode,
    target: std.zig.CrossTarget,
) void {
    const test_exe = b.addTest(zig_imgui_path ++ std.fs.path.sep_str ++ "tests.zig");
    test_exe.setBuildMode(mode);
    test_exe.setTarget(target);
    
    link(test_exe);

    const test_step = b.step(step_name, "Run zig-imgui tests");
    test_step.dependOn(&test_exe.step);
}
