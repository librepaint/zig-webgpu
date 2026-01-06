const std = @import("std");
const printf = std.debug.print;
const Thread = std.Thread;

const vexlib = @import("vexlib");
const await = vexlib.await;
const PromiseState = vexlib.PromiseState;
const Promise = vexlib.Promise;
const Resolver = vexlib.Resolver;
const println = vexlib.println;
const String = vexlib.String;
const Int = vexlib.Int;

// Dawn: /zig-webgpu/dawn/out/Debug/gen/include/dawn/webgpu.h
// wgpu: /zig-webgpu/wgpu-linux-x86_64-debug/include/webgpu/webgpu.h
const webgpu = @import("webgpu");
const GPUCommandBuffer = webgpu.GPUCommandBuffer;
const wgpu = webgpu.wgpu;
const glfw = webgpu.glfw;

fn onDeviceLost(
    device: [*c]const wgpu.WGPUDevice,
    reason: wgpu.WGPUDeviceLostReason,
    message: wgpu.WGPUStringView,
    _: ?*anyopaque, _: ?*anyopaque,
) callconv(.c) void {
    _=device;
    _=reason;

    printf("Device Lost: {s}\n", .{ message.data[0..message.length] });
}

fn onDeviceError(
    device: [*c]const wgpu.WGPUDevice,
    errType: wgpu.WGPUErrorType,
    message: wgpu.WGPUStringView,
    _: ?*anyopaque, _: ?*anyopaque,
) callconv(.c) void {
    _=device;
    _=errType;

    printf("Device Error: {s}\n", .{ message.data[0..message.length] });
}

pub fn main() !void {
    // setup allocator
    var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = generalPurposeAllocator.allocator();
    vexlib.init(&allocator);

    var myGPU = webgpu.gpu.alloc() catch |err| {
        switch (err) {
            webgpu.Error.NOT_AVAILABLE => {
                @panic("GPU_NOT_AVAILABLE");
            },
            else => unreachable
        }
    };

    var context = try webgpu.GPUCanvasContext.alloc(myGPU);

    // get adapter
    var options = wgpu.WGPURequestAdapterOptions{
        .nextInChain = null,
        .featureLevel = webgpu.FeatureLevel.Core,
        .powerPreference = webgpu.PowerPreference.NoPreference,
        .forceFallbackAdapter = webgpu.Bool.False,
        .backendType = webgpu.BackendType.Vulkan,
        .compatibleSurface = context._surface
    };
    const adapterPromise = myGPU.requestAdapter(&options);
    var adapter = await (adapterPromise) catch |err| {
        switch (err) {
            webgpu.Error.NOT_AVAILABLE => {
                println("ADAPTER_NOT_AVAILABLE");
                @panic("");
            },
            else => unreachable
        }
    };
    adapterPromise.free();
    defer adapter.dealloc();

    // get device
    var description = wgpu.WGPUDeviceDescriptor{
        .nextInChain = null,
        .label = wgpu.WGPUStringView{
            .data = String.usingZigString("My Device").cstring(),
            .length = String.usingZigString("My Device").len()
        },
        .requiredFeatureCount = 0,
        .requiredFeatures = null,
        .requiredLimits = null,
        .defaultQueue = wgpu.WGPUQueueDescriptor{
            .nextInChain = null,
            .label = wgpu.WGPUStringView{
                .data = String.usingZigString("My Queue").cstring(),
                .length = String.usingZigString("My Queue").len()
            },
        },
        .deviceLostCallbackInfo = wgpu.WGPUDeviceLostCallbackInfo{
            .nextInChain = null,
            .mode = webgpu.CallbackMode.AllowProcessEvents,
            .callback = onDeviceLost,
            .userdata1 = null,
            .userdata2 = null
        },
        .uncapturedErrorCallbackInfo = wgpu.WGPUUncapturedErrorCallbackInfo{
            .nextInChain = null,
            .callback = onDeviceError,
            .userdata1 = null,
            .userdata2 = null
        }
    };
    const devicePromise = adapter.requestDevice(&description);
    var device = await (devicePromise) catch |err| {
        switch (err) {
            webgpu.Error.NOT_AVAILABLE => {
                @panic("DEVICE_NOT_AVAILABLE");
            },
            else => unreachable
        }
    };
    devicePromise.free();
    defer device.dealloc();


    // Print Info
    printf("WGPU instance: {x}\n", .{@intFromPtr(myGPU._instance)});
    printf("WGPU adapter: {x}\n", .{@intFromPtr(adapter._adapter)});
    printf("WGPU device: {x}\n", .{@intFromPtr(device._device)});

    // print adapter info
    const adapterInfo = adapter.info();
    printf("\nAdapter Info:\n", .{});
    printf(" - Vendor: {s} ({x})\n", .{ adapterInfo.vendor.raw(), adapterInfo.vendorID });
    printf(" - Device: {s} ({x})\n", .{ adapterInfo.device.raw(), adapterInfo.deviceID });
    printf(" - Architecture: {s}\n", .{ adapterInfo.architecture.raw() });
    printf(" - Description: {s}\n", .{ adapterInfo.description.raw() });
    printf(" - Backend: {s} ({x})\n", .{ adapterInfo.backend.raw(), adapterInfo.backendType });
    printf(" - AdapterType: {s} ({x})\n", .{ adapterInfo.adapter.raw(), adapterInfo.adapterType });
    // print adapter limits
    const adapterLimits = adapter.limits();
    printf("\nAdapter limits:\n", .{});
    printf(" - maxTextureDimension1D: {x}\n", .{ adapterLimits.maxTextureDimension1D });
    printf(" - maxTextureDimension2D: {x}\n", .{ adapterLimits.maxTextureDimension2D });
    printf(" - maxTextureDimension3D: {x}\n", .{ adapterLimits.maxTextureDimension3D });
    printf(" - maxTextureArrayLayers: {x}\n", .{ adapterLimits.maxTextureArrayLayers });
    // print adapter supported features
    var adapterFeatures = adapter.features().entries();
    println("\nAdapter Features:");
    while (adapterFeatures.next()) {
        printf(" - {s} ({x})\n", .{ adapterFeatures.key.raw(), adapterFeatures.value });
    }

    // print device info
    // WARNING: Not implemented in WGPU
    // const deviceInfo = device.adapterInfo();
    // printf("\nAdapter Info:\n", .{});
    // printf(" - Vendor: {s} ({x})\n", .{ deviceInfo.vendor.raw(), deviceInfo.vendorID });
    // printf(" - Device: {s} ({x})\n", .{ deviceInfo.device.raw(), deviceInfo.deviceID });
    // printf(" - Architecture: {s}\n", .{ deviceInfo.architecture.raw() });
    // printf(" - Description: {s}\n", .{ deviceInfo.description.raw() });
    // printf(" - Backend: {s} ({x})\n", .{ deviceInfo.backend.raw(), deviceInfo.backendType });
    // printf(" - AdapterType: {s} ({x})\n", .{ deviceInfo.adapter.raw(), deviceInfo.adapterType });
    // print device limits
    const deviceLimits = device.limits();
    printf("\nAdapter limits:\n", .{});
    printf(" - maxTextureDimension1D: {x}\n", .{ deviceLimits.maxTextureDimension1D });
    printf(" - maxTextureDimension2D: {x}\n", .{ deviceLimits.maxTextureDimension2D });
    printf(" - maxTextureDimension3D: {x}\n", .{ deviceLimits.maxTextureDimension3D });
    printf(" - maxTextureArrayLayers: {x}\n", .{ deviceLimits.maxTextureArrayLayers });
    // print device supported features
    var deviceFeatures = device.features().entries();
    println("\nAdapter Features:");
    while (deviceFeatures.next()) {
        printf(" - {s} ({x})\n", .{ deviceFeatures.key.raw(), deviceFeatures.value });
    }


    const surfaceFormat = try webgpu.gpu.getPreferredCanvasFormat(context, adapter);

    // set up glfw surface
    context.configure(wgpu.WGPUSurfaceConfiguration{
        .nextInChain = null,
        .device = device._device,
        .format = surfaceFormat,
        .usage = wgpu.WGPUTextureUsage_RenderAttachment,
        .width = 640,
        .height = 480,
        .viewFormatCount = 0,
        .viewFormats = null,
        .alphaMode = wgpu.WGPUCompositeAlphaMode_Auto,
        .presentMode = wgpu.WGPUPresentMode_Fifo,
    });

    const shaderCode = @embedFile("./triangle_shader.wgsl");
    var shaderCodeDesc = wgpu.WGPUShaderSourceWGSL{
        .chain = wgpu.WGPUChainedStruct{
            .next = null,
            .sType = wgpu.WGPUSType_ShaderSourceWGSL
        },
        .code = wgpu.WGPUStringView{
            .data = String.usingZigString(shaderCode).cstring(),
            .length = String.usingZigString(shaderCode).len()
        },
    };
    var shaderDesc = wgpu.WGPUShaderModuleDescriptor{
        .nextInChain = &shaderCodeDesc.chain
    };
    const shaderModule: wgpu.WGPUShaderModule = wgpu.wgpuDeviceCreateShaderModule(device._device, &shaderDesc);


    var blendState = wgpu.WGPUBlendState{
        .color = wgpu.WGPUBlendComponent{
            .operation = wgpu.WGPUBlendOperation_Add,
            .srcFactor = wgpu.WGPUBlendFactor_SrcAlpha,
            .dstFactor = wgpu.WGPUBlendFactor_OneMinusSrcAlpha,
        },
        .alpha = wgpu.WGPUBlendComponent{
            .operation = wgpu.WGPUBlendOperation_Add,
            .srcFactor = wgpu.WGPUBlendFactor_Zero,
            .dstFactor = wgpu.WGPUBlendFactor_One,
        }
    };
    var colorTarget = wgpu.WGPUColorTargetState{
        .nextInChain = null,
        .format = surfaceFormat,
        .blend = &blendState,
        .writeMask = wgpu.WGPUColorWriteMask_All
    };
    var fragmentState = wgpu.WGPUFragmentState{
        .nextInChain = null,
        .module = shaderModule,
        .entryPoint = wgpu.WGPUStringView{
            .data = String.usingZigString("fs_main").cstring(),
            .length = String.usingZigString("fs_main").len()
        },
        .constantCount = 0,
        .constants = null,
        .targetCount = 1,
        .targets = &colorTarget
    };
    var pipelineDesc = wgpu.WGPURenderPipelineDescriptor{
        .nextInChain = null,
        .label = wgpu.WGPUStringView{
            .data = String.usingZigString("fs_main").cstring(),
            .length = String.usingZigString("fs_main").len()
        },
        .layout = null,
        .vertex = wgpu.WGPUVertexState{
            .nextInChain = null,
            .module = shaderModule,
            .entryPoint = wgpu.WGPUStringView{
                .data = String.usingZigString("vs_main").cstring(),
                .length = String.usingZigString("vs_main").len()
            },
            .constantCount = 0,
            .constants = null,
            .bufferCount = 0,
            .buffers = null
        },
        .primitive = wgpu.WGPUPrimitiveState{
            .nextInChain = null,
            .topology = wgpu.WGPUPrimitiveTopology_TriangleList,
            .stripIndexFormat = wgpu.WGPUIndexFormat_Undefined,
            .frontFace = wgpu.WGPUFrontFace_CCW,
            .cullMode = wgpu.WGPUCullMode_None,
            .unclippedDepth = webgpu.Bool.False
        },
        .depthStencil = null,
        .multisample = wgpu.WGPUMultisampleState{
            .nextInChain = null,
            .count = 1,
            .mask = Int.MAX.u32,
            .alphaToCoverageEnabled = webgpu.Bool.False,
        },
        .fragment = &fragmentState
    };
    // [...] Describe render pipeline
    const pipeline = wgpu.wgpuDeviceCreateRenderPipeline(device._device, &pipelineDesc);

    var workDonePromise = device.queue.onSubmittedWorkDone();

    var commandEncoder = device.createCommandEncoder(null);
    commandEncoder.insertDebugMarker(String.usingZigString("Do one thing"));
    commandEncoder.insertDebugMarker(String.usingZigString("Do two thing"));

    // get texture and view of surface
    var surfaceTexture = try context.getCurrentTexture();
    const textureView = surfaceTexture.createView();

    var renderPassColorAttachment = wgpu.WGPURenderPassColorAttachment{
        .nextInChain = null,
        .view = textureView,
        .depthSlice = wgpu.WGPU_DEPTH_SLICE_UNDEFINED,
        .resolveTarget = null,
        .loadOp = wgpu.WGPULoadOp_Clear,
        .storeOp = wgpu.WGPUStoreOp_Store,
        .clearValue = wgpu.WGPUColor{
            .r = 1.0,
            .g = 0.0,
            .b = 0.0,
            .a = 1.0,
        }
    };
    var renderPass = commandEncoder.beginRenderPass(wgpu.WGPURenderPassDescriptor{
        .nextInChain = null,
        .label = wgpu.WGPUStringView{
            .data = String.usingZigString("Surface texture view").cstring(),
            .length = String.usingZigString("Surface texture view").len()
        },
        .colorAttachmentCount = 1,
        .colorAttachments = &renderPassColorAttachment,
        .depthStencilAttachment = null,
        .occlusionQuerySet = null,
        .timestampWrites = null
    });

    wgpu.wgpuRenderPassEncoderSetPipeline(renderPass._encoder, pipeline);
    wgpu.wgpuRenderPassEncoderDraw(renderPass._encoder, 3, 1, 0, 0);

    renderPass.end();
    renderPass.dealloc();

    const command = commandEncoder.finish(String.usingZigString("Command Buffer"));
    commandEncoder.dealloc();

    var commands = [_]GPUCommandBuffer{ command };
    device.queue.submit(commands[0..]);
    webgpu.releaseCommandBuffer(command);

    const workStatusCode = await (workDonePromise);
    workDonePromise.free();
    printf("Work finished with status {x}\n", .{ workStatusCode });

    wgpu.wgpuRenderPipelineRelease(pipeline);

    _= wgpu.wgpuSurfacePresent(context._surface);
    wgpu.wgpuTextureViewRelease(textureView);
    wgpu.wgpuTextureRelease(surfaceTexture._texture.texture);

    while (glfw.glfwWindowShouldClose(context._window) == 0) {
        glfw.glfwPollEvents();
    }

    context.dealloc();

    println("Exiting...");
}
