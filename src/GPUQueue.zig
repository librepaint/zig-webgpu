const vexlib = @import("vexlib");
const Promise = vexlib.Promise;

const wgpu = @import("./c.zig").wgpu;

const types = @import("./types.zig");
const CallbackMode = types.CallbackMode;

const utils = @import("./utils.zig");
const denull = utils.denull;



var _requestQueue: ?denull(wgpu.WGPUQueue) = null;

_queue: wgpu.WGPUQueue,

const Self = @This();

pub fn alloc(queue: wgpu.WGPUQueue) Self {
    return Self{
        ._queue = queue
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuQueueRelease(self._queue);
}

pub fn submit(self: *Self, commandBuffers: []wgpu.WGPUCommandBuffer) void {
    wgpu.wgpuQueueSubmit(self._queue, commandBuffers.len, commandBuffers.ptr);
}

pub fn onSubmittedWorkDone(self: *Self) *Promise(wgpu.WGPUQueueWorkDoneStatus) {
    const Promise_ = Promise(wgpu.WGPUQueueWorkDoneStatus);

    _requestQueue = self._queue;

    return Promise_.new(struct{fn f(promise: *Promise_) void {
        const requestId = wgpu.wgpuQueueOnSubmittedWorkDone(_requestQueue, wgpu.WGPUQueueWorkDoneCallbackInfo{
            .nextInChain = null,
            .mode = CallbackMode.AllowProcessEvents,
            .callback = onSubmittedWorkDoneCallback,
            .userdata1 = promise,
            .userdata2 = null,
        }).id;
        _=requestId;
    }}.f);
}

fn onSubmittedWorkDoneCallback(
    status: wgpu.WGPUQueueWorkDoneStatus,
    userData: ?*anyopaque,
    _: ?*anyopaque
) callconv(.c) void {
    const promise: *Promise(wgpu.WGPUQueueWorkDoneStatus) = @ptrCast(@alignCast(userData));
    promise.resolve(status);
}