const std = @import("std");

pub const printf = std.debug.print;

const wgpu = @import("./c.zig").wgpu;

pub fn sliceFromWGPUString(view: wgpu.WGPUStringView) []const u8 {
    if (view.data == null) {
        return "";
    }
    return view.data[0..view.length];
}

pub fn denull(comptime T: type) type {
    return @typeInfo(T).optional.child;
}