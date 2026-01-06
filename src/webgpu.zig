const c = @import("./c.zig");
pub const wgpu = c.wgpu;
pub const glfw = c.glfw;
pub const x11 = c.x11;

const types = @import("./types.zig");
pub const FeatureLevel = types.FeatureLevel;
pub const PowerPreference = types.PowerPreference;
pub const Bool = types.Bool;
pub const CallbackMode = types.CallbackMode;
pub const Feature = types.Feature;
pub const FeatureName = types.FeatureName;
pub const BackendType = types.BackendType;
pub const BackendTypeName = types.BackendTypeName;
pub const AdapterType = types.AdapterType;
pub const AdapterTypeName = types.AdapterTypeName;
pub const GPUAdapterInfo = types.GPUAdapterInfo;
pub const GPUSupportedLimits = types.GPUSupportedLimits;
pub const GPUSupportedFeatures = types.GPUSupportedFeatures;
pub const Error = types.Error;

pub const GPUAdapter = @import("./GPUAdapter.zig");
pub const GPUCanvasContext = @import("./GPUCanvasContext.zig");
pub const GPURenderPassEncoder = @import("./GPURenderPassEncoder.zig");
pub const GPUCommandBuffer = wgpu.WGPUCommandBuffer;
pub const GPUCommandEncoder = @import("./GPUCommandEncoder.zig");
pub const GPUDevice = @import("./GPUDevice.zig");
pub const GPUQueue = @import("./GPUQueue.zig");
pub const GPUTexture = @import("./GPUTexture.zig");
pub const gpu = @import("./gpu.zig");

pub fn releaseCommandBuffer(commandBuffer: GPUCommandBuffer) void {
    wgpu.wgpuCommandBufferRelease(commandBuffer);
}