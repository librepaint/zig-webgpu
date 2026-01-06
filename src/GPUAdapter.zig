const vexlib = @import("vexlib");
const As = vexlib.As;
const Promise = vexlib.Promise;
const String = vexlib.String;
const Int = vexlib.Int;

const c = @import("./c.zig");
const wgpu = c.wgpu;

const types = @import("./types.zig");
const GPUSupportedFeatures = types.GPUSupportedFeatures;
const GPUAdapterInfo = types.GPUAdapterInfo;
const GPUSupportedLimits = types.GPUSupportedLimits;
const Error = types.Error;
const CallbackMode = types.CallbackMode;
const FeatureName = types.FeatureName;
const AdapterTypeName = types.AdapterTypeName;
const BackendTypeName = types.BackendTypeName;

const GPUDevice = @import("./GPUDevice.zig");

const utils = @import("./utils.zig");
const sliceFromWGPUString = utils.sliceFromWGPUString;
const denull = utils.denull;
const printf = utils.printf;

const gpu = @import("./gpu.zig");



_adapter: wgpu.WGPUAdapter,
_features: ?GPUSupportedFeatures = null,
_info: ?GPUAdapterInfo = null,
_limits: ?GPUSupportedLimits = null,

const Self = @This();

var _requestDeviceAdapter: ?denull(wgpu.WGPUAdapter) = null;
var _requestDeviceDescriptor: *wgpu.WGPUDeviceDescriptor = undefined;

pub fn alloc(adapter: wgpu.WGPUAdapter) Self {
    return Self{
        ._adapter = adapter
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuAdapterRelease(self._adapter);
}

pub fn requestDevice(self: *Self, descriptor: *wgpu.WGPUDeviceDescriptor) *Promise(Error!GPUDevice) {
    const Promise_ = Promise(Error!GPUDevice);

    Self._requestDeviceAdapter = self._adapter;
    Self._requestDeviceDescriptor = descriptor;

    return Promise_.new(struct{fn f(promise: *Promise_) void {
        const requestId = wgpu.wgpuAdapterRequestDevice(
            Self._requestDeviceAdapter,
            Self._requestDeviceDescriptor,
            wgpu.WGPURequestDeviceCallbackInfo{
                .nextInChain = null,
                .mode = CallbackMode.AllowProcessEvents,
                .callback = requestDeviceCallback,
                .userdata1 = promise,
                .userdata2 = null,
            }
        ).id;
        _=requestId;
    }}.f);
}

fn requestDeviceCallback(
    status: wgpu.WGPURequestDeviceStatus,
    device: wgpu.WGPUDevice,
    message: wgpu.WGPUStringView,
    userData: ?*anyopaque,
    _: ?*anyopaque
) callconv(.c) void {
    const promise: *Promise(Error!GPUDevice) = @ptrCast(@alignCast(userData));
    if (status == wgpu.WGPURequestDeviceStatus_Success) {
        promise.resolve(GPUDevice.alloc(device));
    } else {
        printf("Could not get WebGPU device: {s}\n", .{ message.data[0..message.length] });
        promise.resolve(Error.NOT_AVAILABLE);
    }
}

pub fn features(self: *Self) GPUSupportedFeatures {
    if (self._features == null) {
        var supportedFeatures = wgpu.WGPUSupportedFeatures{};
        wgpu.wgpuAdapterGetFeatures(self._adapter, &supportedFeatures);
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

pub fn info(self: *Self) GPUAdapterInfo {
    if (self._info == null) {
        var adapterInfo = wgpu.WGPUAdapterInfo{
            .nextInChain = null
        };
        _= wgpu.wgpuAdapterGetInfo(self._adapter, &adapterInfo);
        
        self._info = GPUAdapterInfo{
            .architecture = String.usingSlice(sliceFromWGPUString(adapterInfo.architecture)),

            .adapter = String.usingZigString(AdapterTypeName[adapterInfo.adapterType]),
            .adapterType = adapterInfo.adapterType,

            .backend = String.usingZigString(BackendTypeName[adapterInfo.backendType]),
            .backendType = adapterInfo.backendType,

            .description = String.usingSlice(sliceFromWGPUString(adapterInfo.description)),

            .device = String.usingSlice(sliceFromWGPUString(adapterInfo.device)),
            .deviceID = adapterInfo.deviceID,
            
            .vendor = String.usingSlice(sliceFromWGPUString(adapterInfo.vendor)),
            .vendorID = adapterInfo.vendorID,
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
        const success = wgpu.wgpuAdapterGetLimits(self._adapter, &wgpuLimits) == 1;
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
