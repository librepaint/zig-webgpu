const vexlib = @import("vexlib");
const Promise = vexlib.Promise;

const wgpu = @import("./c.zig").wgpu;

const types = @import("./types.zig");
const CallbackMode = types.CallbackMode;
const Error = types.Error;

const GPUAdapter = @import("./GPUAdapter.zig");
const GPUCanvasContext = @import("./GPUCanvasContext.zig");

const utils = @import("./utils.zig");
const denull = utils.denull;
const printf = utils.printf;



_instance: ?denull(wgpu.WGPUInstance) = null,

var _requestInstance: ?denull(wgpu.WGPUInstance) = null;
var _requestOptions: *wgpu.WGPURequestAdapterOptions = undefined;

const Self = @This();

pub fn alloc() Error!Self {
    var desc = wgpu.WGPUInstanceDescriptor{
        .nextInChain = null,
    };
    _requestInstance = wgpu.wgpuCreateInstance(&desc);
    if (_requestInstance == null) {
        return Error.NOT_AVAILABLE;
    }
    return Self{
        ._instance = _requestInstance
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuInstanceRelease(self._instance);
}

pub fn requestAdapter(self: *Self, options: *wgpu.WGPURequestAdapterOptions) *Promise(Error!GPUAdapter) {
    _=self;

    const Promise_ = Promise(Error!GPUAdapter);

    _requestOptions = options;

    return Promise_.new(struct{fn f(promise: *Promise_) void {
        const requestId = wgpu.wgpuInstanceRequestAdapter(
            _requestInstance,
            _requestOptions,
            wgpu.WGPURequestAdapterCallbackInfo{
                .nextInChain = null,
                .mode = CallbackMode.AllowProcessEvents,
                .callback = requestAdapterCallback,
                .userdata1 = promise,
                .userdata2 = null,
            }
        ).id;
        _=requestId;
    }}.f);
}

pub fn getPreferredCanvasFormat(context: GPUCanvasContext, adapter: GPUAdapter) Error!wgpu.WGPUTextureFormat {
    var capabilities = wgpu.WGPUSurfaceCapabilities{
        .nextInChain = null
    };
    const status = wgpu.wgpuSurfaceGetCapabilities(context._surface, adapter._adapter, &capabilities);
    if (status != wgpu.WGPUStatus_Success) {
        return Error.FAIL;
    }
    return capabilities.formats[0];
}

fn requestAdapterCallback(
    status: wgpu.WGPURequestAdapterStatus,
    adapter: wgpu.WGPUAdapter,
    message: wgpu.WGPUStringView,
    userData: ?*anyopaque,
    _: ?*anyopaque
) callconv(.c) void {
    const promise: *Promise(Error!GPUAdapter) = @ptrCast(@alignCast(userData));
    if (status == wgpu.WGPURequestAdapterStatus_Success) {
        promise.resolve(GPUAdapter.alloc(adapter));
    } else {
        printf("Could not get WebGPU adapter: {s}\n", .{ message.data[0..message.length] });
        promise.resolve(Error.NOT_AVAILABLE);
    }
}
