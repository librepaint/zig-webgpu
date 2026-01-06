const vexlib = @import("vexlib");
const String = vexlib.String;

const wgpu = @import("./c.zig").wgpu;

const GPURenderPassEncoder = @import("./GPURenderPassEncoder.zig");



_encoder: wgpu.WGPUCommandEncoder,

const Self = @This();

pub fn alloc(encoder: wgpu.WGPUCommandEncoder) Self {
    return Self{
        ._encoder = encoder
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuCommandEncoderRelease(self._encoder);
}

pub fn insertDebugMarker(self: *Self, label: String) void {
    wgpu.wgpuCommandEncoderInsertDebugMarker(self._encoder, wgpu.WGPUStringView{
        .data = label.cstring(),
        .length = label.len()
    });
}

pub fn beginRenderPass(self: *Self, renderPassDescriptor: wgpu.WGPURenderPassDescriptor) GPURenderPassEncoder {
    return GPURenderPassEncoder.alloc(wgpu.wgpuCommandEncoderBeginRenderPass(self._encoder, &renderPassDescriptor));
}

pub fn finish(self: *Self, label: ?String) wgpu.WGPUCommandBuffer {
    var encoderDesc = wgpu.WGPUCommandBufferDescriptor{
        .nextInChain = null,
        .label = undefined
    };
    if (label == null) {
        encoderDesc.label = wgpu.WGPUStringView{
            .data = null,
            .length = 0
        };
    } else {
        encoderDesc.label = wgpu.WGPUStringView{
            .data = label.?.cstring(),
            .length = label.?.len()
        };
    }
    return wgpu.wgpuCommandEncoderFinish(self._encoder, &encoderDesc);
}