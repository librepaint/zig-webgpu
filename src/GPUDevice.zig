const vexlib = @import("vexlib");
const As = vexlib.As;
const String = vexlib.String;
const Int = vexlib.Int;

const wgpu = @import("./c.zig").wgpu;

const types = @import("./types.zig");
const GPUSupportedFeatures = types.GPUSupportedFeatures;
const GPUAdapterInfo = types.GPUAdapterInfo;
const GPUSupportedLimits = types.GPUSupportedLimits;
const FeatureName = types.FeatureName;
const AdapterTypeName = types.AdapterTypeName;
const BackendTypeName = types.BackendTypeName;

const GPUAdapter = @import("./GPUAdapter.zig");
const GPUQueue = @import("./GPUQueue.zig");
const GPUCommandEncoder = @import("./GPUCommandEncoder.zig");

const utils = @import("./utils.zig");
const sliceFromWGPUString = utils.sliceFromWGPUString;

queue: GPUQueue,

_device: wgpu.WGPUDevice,
_features: ?GPUSupportedFeatures = null,
_info: ?GPUAdapterInfo = null,
_limits: ?GPUSupportedLimits = null,

const Self = @This();

pub fn alloc(device: wgpu.WGPUDevice) Self {
    return Self{
        ._device = device,
        .queue = GPUQueue.alloc(wgpu.wgpuDeviceGetQueue(device))
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuDeviceRelease(self._device);
    self.queue.dealloc();
}

pub fn features(self: *Self) GPUSupportedFeatures {
    if (self._features == null) {
        var supportedFeatures = wgpu.WGPUSupportedFeatures{};
        wgpu.wgpuDeviceGetFeatures(self._device, &supportedFeatures);
        self._features = GPUSupportedFeatures.alloc(As.u32(supportedFeatures.featureCount));
        {var i: usize = 0; while (i < supportedFeatures.featureCount) : (i += 1) {
            const feature = supportedFeatures.features[i];
            if (feature < FeatureName.len) {
                self._features.?.set(String.usingZigString(FeatureName[feature]), feature);
            } else {
                self._features.?.set(Int.toString(feature, 10), feature);
            }
        }}
    }

    return self._features.?;
}

pub fn adapterInfo(self: *Self) GPUAdapterInfo {
    if (self._info == null) {
        const info = wgpu.wgpuDeviceGetAdapterInfo(self._device);
        
        self._info = GPUAdapterInfo{
            .architecture = String.usingSlice(sliceFromWGPUString(info.architecture)),

            .adapter = String.usingZigString(AdapterTypeName[info.adapterType]),
            .adapterType = info.adapterType,

            .backend = String.usingZigString(BackendTypeName[info.backendType]),
            .backendType = info.backendType,

            .description = String.usingSlice(sliceFromWGPUString(info.description)),

            .device = String.usingSlice(sliceFromWGPUString(info.device)),
            .deviceID = info.deviceID,
            
            .vendor = String.usingSlice(sliceFromWGPUString(info.vendor)),
            .vendorID = info.vendorID,
        };
    }

    return self._info.?;
}

pub fn limits(self: *Self) GPUSupportedLimits {
    if (self._limits == null) {
        self._limits = GPUSupportedLimits{
            .maxTextureDimension1D = 0,
            .maxTextureDimension2D = 0,
            .maxTextureDimension3D = 0,
            .maxTextureArrayLayers = 0,
            .maxBindGroups = 0,
            .maxBindGroupsPlusVertexBuffers = 0,
            .maxBindingsPerBindGroup = 0,
            .maxDynamicUniformBuffersPerPipelineLayout = 0,
            .maxDynamicStorageBuffersPerPipelineLayout = 0,
            .maxSampledTexturesPerShaderStage = 0,
            .maxSamplersPerShaderStage = 0,
            .maxStorageBuffersPerShaderStage = 0,
            .maxStorageTexturesPerShaderStage = 0,
            .maxUniformBuffersPerShaderStage = 0,
            .maxUniformBufferBindingSize = 0,
            .maxStorageBufferBindingSize = 0,
            .minUniformBufferOffsetAlignment = 0,
            .minStorageBufferOffsetAlignment = 0,
            .maxVertexBuffers = 0,
            .maxBufferSize = 0,
            .maxVertexAttributes = 0,
            .maxVertexBufferArrayStride = 0,
            .maxInterStageShaderVariables = 0,
            .maxColorAttachments = 0,
            .maxColorAttachmentBytesPerSample = 0,
            .maxComputeWorkgroupStorageSize = 0,
            .maxComputeInvocationsPerWorkgroup = 0,
            .maxComputeWorkgroupSizeX = 0,
            .maxComputeWorkgroupSizeY = 0,
            .maxComputeWorkgroupSizeZ = 0,
            .maxComputeWorkgroupsPerDimension = 0,
        };

        var wgpuLimits = wgpu.WGPULimits{
            .nextInChain = null
        };
        const success = wgpu.wgpuDeviceGetLimits(self._device, &wgpuLimits) == 1;
        if (success) {
            self._limits = GPUSupportedLimits{
                .maxTextureDimension1D = wgpuLimits.maxTextureDimension1D,
                .maxTextureDimension2D = wgpuLimits.maxTextureDimension2D,
                .maxTextureDimension3D = wgpuLimits.maxTextureDimension3D,
                .maxTextureArrayLayers = wgpuLimits.maxTextureArrayLayers,
                .maxBindGroups = wgpuLimits.maxBindGroups,
                .maxBindGroupsPlusVertexBuffers = wgpuLimits.maxBindGroupsPlusVertexBuffers,
                .maxBindingsPerBindGroup = wgpuLimits.maxBindingsPerBindGroup,
                .maxDynamicUniformBuffersPerPipelineLayout = wgpuLimits.maxDynamicUniformBuffersPerPipelineLayout,
                .maxDynamicStorageBuffersPerPipelineLayout = wgpuLimits.maxDynamicStorageBuffersPerPipelineLayout,
                .maxSampledTexturesPerShaderStage = wgpuLimits.maxSampledTexturesPerShaderStage,
                .maxSamplersPerShaderStage = wgpuLimits.maxSamplersPerShaderStage,
                .maxStorageBuffersPerShaderStage = wgpuLimits.maxStorageBuffersPerShaderStage,
                .maxStorageTexturesPerShaderStage = wgpuLimits.maxStorageTexturesPerShaderStage,
                .maxUniformBuffersPerShaderStage = wgpuLimits.maxUniformBuffersPerShaderStage,
                .maxUniformBufferBindingSize = wgpuLimits.maxUniformBufferBindingSize,
                .maxStorageBufferBindingSize = wgpuLimits.maxStorageBufferBindingSize,
                .minUniformBufferOffsetAlignment = wgpuLimits.minUniformBufferOffsetAlignment,
                .minStorageBufferOffsetAlignment = wgpuLimits.minStorageBufferOffsetAlignment,
                .maxVertexBuffers = wgpuLimits.maxVertexBuffers,
                .maxBufferSize = wgpuLimits.maxBufferSize,
                .maxVertexAttributes = wgpuLimits.maxVertexAttributes,
                .maxVertexBufferArrayStride = wgpuLimits.maxVertexBufferArrayStride,
                .maxInterStageShaderVariables = wgpuLimits.maxInterStageShaderVariables,
                .maxColorAttachments = wgpuLimits.maxColorAttachments,
                .maxColorAttachmentBytesPerSample = wgpuLimits.maxColorAttachmentBytesPerSample,
                .maxComputeWorkgroupStorageSize = wgpuLimits.maxComputeWorkgroupStorageSize,
                .maxComputeInvocationsPerWorkgroup = wgpuLimits.maxComputeInvocationsPerWorkgroup,
                .maxComputeWorkgroupSizeX = wgpuLimits.maxComputeWorkgroupSizeX,
                .maxComputeWorkgroupSizeY = wgpuLimits.maxComputeWorkgroupSizeY,
                .maxComputeWorkgroupSizeZ = wgpuLimits.maxComputeWorkgroupSizeZ,
                .maxComputeWorkgroupsPerDimension = wgpuLimits.maxComputeWorkgroupsPerDimension,
            };
        }
    }

    return self._limits.?;
}

pub fn createCommandEncoder(self: *Self, label: ?String) GPUCommandEncoder {
    var encoderDesc = wgpu.WGPUCommandEncoderDescriptor{
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
    const encoder = wgpu.wgpuDeviceCreateCommandEncoder(self._device, &encoderDesc);
    return GPUCommandEncoder.alloc(encoder);
}