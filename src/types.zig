const vexlib = @import("vexlib");
const String = vexlib.String;
const ListMap = vexlib.ListMap;

const wgpu = @import("./c.zig").wgpu;



pub const FeatureLevel = struct {
    /// "Compatibility" profile which can be supported on OpenGL ES 3.1.
    pub const Compatability = 0x00000001;
    /// "Core" profile which can be supported on Vulkan/Metal/D3D12.
    pub const Core = 0x00000002;
};

pub const PowerPreference = struct {
    pub const NoPreference = 0x00000000;
    pub const LowPower = 0x00000001;
    pub const HighPerformance = 0x00000002;
};

pub const Bool = struct {
    pub const False = 0;
    pub const True = 1;
};

pub const CallbackMode = struct {
    /// Callbacks created with `WGPUCallbackMode_WaitAnyOnly`:
    /// - fire when the asynchronous operation's future is passed to a call to `::wgpuInstanceWaitAny`
    ///   AND the operation has already completed or it completes inside the call to `::wgpuInstanceWaitAny`.
    pub const WaitAnyOnly = 0x00000001;

    // Callbacks created with `WGPUCallbackMode_AllowProcessEvents`:
    // - fire for the same reasons as callbacks created with `WGPUCallbackMode_WaitAnyOnly`
    // - fire inside a call to `::wgpuInstanceProcessEvents` if the asynchronous operation is complete.
    pub const AllowProcessEvents = 0x00000002;
    
    /// Callbacks created with `WGPUCallbackMode_AllowSpontaneous`:
    /// - fire for the same reasons as callbacks created with `WGPUCallbackMode_AllowProcessEvents`
    /// - **may** fire spontaneously on an arbitrary or application thread, when the WebGPU implementations discovers that the asynchronous operation is complete.
    /// 
    ///   Implementations _should_ fire spontaneous callbacks as soon as possible.
    /// 
    /// @note Because spontaneous callbacks may fire at an arbitrary time on an arbitrary thread, applications should take extra care when acquiring locks or mutating state inside the callback. It undefined behavior to re-entrantly call into the webgpu.h API if the callback fires while inside the callstack of another webgpu.h function that is not `wgpuInstanceWaitAny` or `wgpuInstanceProcessEvents`.
    pub const AllowSpontaneous = 0x00000003;
};

pub const Feature = struct {
    pub const Undefined = 0x00000000;
    pub const DepthClipControl = 0x00000001;
    pub const Depth32FloatStencil8 = 0x00000002;
    pub const TimestampQuery = 0x00000003;
    pub const TextureCompressionBC = 0x00000004;
    pub const TextureCompressionBCSliced3D = 0x00000005;
    pub const TextureCompressionETC2 = 0x00000006;
    pub const TextureCompressionASTC = 0x00000007;
    pub const TextureCompressionASTCSliced3D = 0x00000008;
    pub const IndirectFirstInstance = 0x00000009;
    pub const ShaderF16 = 0x0000000A;
    pub const RG11B10UfloatRenderable = 0x0000000B;
    pub const BGRA8UnormStorage = 0x0000000C;
    pub const Float32Filterable = 0x0000000D;
    pub const Float32Blendable = 0x0000000E;
    pub const ClipDistances = 0x0000000F;
    pub const DualSourceBlending = 0x00000010;
};

pub const FeatureName = [_][:0]const u8 {
    "Undefined",
    "DepthClipControl",
    "Depth32FloatStencil8",
    "TimestampQuery",
    "TextureCompressionBC",
    "TextureCompressionBCSliced3D",
    "TextureCompressionETC2",
    "TextureCompressionASTC",
    "TextureCompressionASTCSliced3D",
    "IndirectFirstInstance",
    "ShaderF16",
    "RG11B10UfloatRenderable",
    "BGRA8UnormStorage",
    "Float32Filterable",
    "Float32Blendable",
    "ClipDistances",
    "DualSourceBlending",
};

pub const BackendType = struct {
    // `0x00000000`.
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    pub const Undefined = 0x00000000;
    pub const Null = 0x00000001;
    pub const WebGPU = 0x00000002;
    pub const D3D11 = 0x00000003;
    pub const D3D12 = 0x00000004;
    pub const Metal = 0x00000005;
    pub const Vulkan = 0x00000006;
    pub const OpenGL = 0x00000007;
    pub const OpenGLES = 0x00000008;
};

pub const BackendTypeName = [_][:0]const u8 {
    "Undefined",
    "Null",
    "WebGPU",
    "D3D11",
    "D3D12",
    "Metal",
    "Vulkan",
    "OpenGL",
    "OpenGLES",
};

pub const AdapterType = struct {
    pub const DiscreteGPU = 0x00000001;
    pub const IntegratedGPU = 0x00000002;
    pub const CPU = 0x00000003;
    pub const Unknown = 0x00000004;
};

pub const AdapterTypeName = [_][:0]const u8 {
    "Undefined",
    "DiscreteGPU",
    "IntegratedGPU",
    "CPU",
    "Unknown",
};

pub const GPUAdapterInfo = struct {
    architecture: String,
    adapter: String,
    adapterType: u32,
    backend: String,
    backendType: u32,
    description: String,
    device: String,
    deviceID: u32,
    vendor: String,
    vendorID: u32,
};

pub const GPUSupportedLimits = extern struct {
    maxTextureDimension1D: u32,
    maxTextureDimension2D: u32,
    maxTextureDimension3D: u32,
    maxTextureArrayLayers: u32,
    maxBindGroups: u32,
    maxBindGroupsPlusVertexBuffers: u32,
    maxBindingsPerBindGroup: u32,
    maxDynamicUniformBuffersPerPipelineLayout: u32,
    maxDynamicStorageBuffersPerPipelineLayout: u32,
    maxSampledTexturesPerShaderStage: u32,
    maxSamplersPerShaderStage: u32,
    maxStorageBuffersPerShaderStage: u32,
    maxStorageTexturesPerShaderStage: u32,
    maxUniformBuffersPerShaderStage: u32,
    maxUniformBufferBindingSize: u64,
    maxStorageBufferBindingSize: u64,
    minUniformBufferOffsetAlignment: u32,
    minStorageBufferOffsetAlignment: u32,
    maxVertexBuffers: u32,
    maxBufferSize: u64,
    maxVertexAttributes: u32,
    maxVertexBufferArrayStride: u32,
    maxInterStageShaderVariables: u32,
    maxColorAttachments: u32,
    maxColorAttachmentBytesPerSample: u32,
    maxComputeWorkgroupStorageSize: u32,
    maxComputeInvocationsPerWorkgroup: u32,
    maxComputeWorkgroupSizeX: u32,
    maxComputeWorkgroupSizeY: u32,
    maxComputeWorkgroupSizeZ: u32,
    maxComputeWorkgroupsPerDimension: u32,
};

pub const GPUSupportedFeatures = ListMap(String, u32);

pub const Error = error {
    NOT_AVAILABLE,
    FAIL
};
