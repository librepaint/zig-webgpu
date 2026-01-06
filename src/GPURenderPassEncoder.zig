const vexlib = @import("vexlib");
const String = vexlib.String;

const wgpu = @import("./c.zig").wgpu;



_encoder: wgpu.WGPURenderPassEncoder,

const Self = @This();

pub fn alloc(encoder: wgpu.WGPURenderPassEncoder) Self {
    return Self{
        ._encoder = encoder
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuRenderPassEncoderRelease(self._encoder);
}

pub fn end(self: *Self) void {
    wgpu.wgpuRenderPassEncoderEnd(self._encoder);
}