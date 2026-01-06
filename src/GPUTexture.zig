const vexlib = @import("vexlib");
const String = vexlib.String;

const webgpu = @import("./webgpu.zig");

const c = @import("./c.zig");
const wgpu = c.wgpu;



_texture: wgpu.WGPUSurfaceTexture,

const Self = @This();

pub fn alloc(texture: wgpu.WGPUSurfaceTexture) Self {
    return Self{
        ._texture = texture
    };
}

pub fn createView(self: *Self) wgpu.WGPUTextureView {
    var viewDescriptor = wgpu.WGPUTextureViewDescriptor{
        .nextInChain = null,
        .label = wgpu.WGPUStringView{
            .data = String.usingZigString("Surface texture view").cstring(),
            .length = String.usingZigString("Surface texture view").len()
        },
        .format = wgpu.wgpuTextureGetFormat(self._texture.texture),
        .dimension = wgpu.WGPUTextureViewDimension_2D,
        .baseMipLevel = 0,
        .mipLevelCount = 1,
        .baseArrayLayer = 0,
        .arrayLayerCount = 1,
        .aspect = wgpu.WGPUTextureAspect_All,
    };
    const targetView: wgpu.WGPUTextureView = wgpu.wgpuTextureCreateView(self._texture.texture, &viewDescriptor);
    return targetView;
}