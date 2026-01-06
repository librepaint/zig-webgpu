const c = @import("./c.zig");
const wgpu = c.wgpu;
const glfw = c.glfw;
const x11 = c.x11;

const webgpu = @import("./webgpu.zig");
const GPUTexture = webgpu.GPUTexture;

const types = @import("./types.zig");
const Error = types.Error;



_window: ?*glfw.GLFWwindow,
_surface: wgpu.WGPUSurface,

const Self = @This();

pub fn alloc(_gpu: webgpu.gpu) Error!Self {
    // init SDL
    // try window.initSDL(window.INIT_EVERYTHING);
    // const myWindow = try window.SDLWindow.alloc(.{
    //     .title = "Triangle",
    //     .width = 800,
    //     .height = 800,
    //     .flags = window.WINDOW_SHOWN | window.WINDOW_ALLOW_HIGHDPI
    // });
    // myWindow.eventHandler = eventHandler; // attach event handler

    if (glfw.glfwInit() == 0) {
        @panic("Could not initialize GLFW!");
    }
    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
    glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, glfw.GLFW_FALSE);
    const myWindow: ?*glfw.GLFWwindow = glfw.glfwCreateWindow(640, 480, "Zig WebGPU Triangle", null, null);
    if (myWindow == null) {
        glfw.glfwTerminate();
        return Error.FAIL;
    }

    // const compatibleSurface = SDL_GetWGPUSurface(myGPU._instance, myWindow.sdlWindow);

    return Self{
        ._window = myWindow,
        ._surface = GLFW_GetWGPUSurface(_gpu._instance, myWindow.?)
    };
}

pub fn dealloc(self: *Self) void {
    wgpu.wgpuSurfaceUnconfigure(self._surface);
    wgpu.wgpuSurfaceRelease(self._surface);
    glfw.glfwDestroyWindow(self._window);
    glfw.glfwTerminate();
}

pub fn configure(self: *Self, config: wgpu.WGPUSurfaceConfiguration) void {
    wgpu.wgpuSurfaceConfigure(self._surface, &config);
}

pub fn getCurrentTexture(self: *Self) Error!GPUTexture {
    var surfaceTexture: wgpu.WGPUSurfaceTexture = undefined;
    wgpu.wgpuSurfaceGetCurrentTexture(self._surface, &surfaceTexture);
    if (surfaceTexture.status != wgpu.WGPUSurfaceGetCurrentTextureStatus_SuccessOptimal) {
        return Error.FAIL;
    }
    return GPUTexture.alloc(surfaceTexture);
}

pub extern fn glfwGetX11Display() ?*x11.Display;
pub extern fn glfwGetX11Window(_window: *glfw.GLFWwindow) x11.Window;
fn GLFW_GetWGPUSurface(instance: wgpu.WGPUInstance, _window: *glfw.GLFWwindow) wgpu.WGPUSurface {
    const x11_display: ?*x11.Display = glfwGetX11Display();
    const x11_window: x11.Window = glfwGetX11Window(_window);

    var fromXlibWindow = wgpu.WGPUSurfaceSourceXlibWindow{
        .chain = wgpu.WGPUChainedStruct{
            .next = null,
            .sType = wgpu.WGPUSType_SurfaceSourceXlibWindow
        },
        .display = x11_display,
        .window = x11_window
    };

    var surfaceDescriptor = wgpu.WGPUSurfaceDescriptor{
        .nextInChain = &(fromXlibWindow.chain),
        .label = wgpu.WGPUStringView{
            .data = null,
            .length = 0
        }
    };

    return wgpu.wgpuInstanceCreateSurface(instance, &surfaceDescriptor);
}

// fn SDL_GetWGPUSurface(instance: wgpu.WGPUInstance, _window: *sdl.SDL_Window) wgpu.WGPUSurface {
//     var windowWMInfo: sdl.SDL_SysWMinfo = undefined;
//     windowWMInfo.version.major = sdl.SDL_MAJOR_VERSION;
//     windowWMInfo.version.minor = sdl.SDL_MINOR_VERSION;
//     windowWMInfo.version.patch = sdl.SDL_PATCHLEVEL;

//     if (sdl.SDL_GetWindowWMInfo(_window, &windowWMInfo) == sdl.SDL_FALSE) {
//         @panic("Failed to get SDL Window WM Info");
//     }

//     const x11_display: ?*x11.Display = windowWMInfo.info.x11.display;
//     const x11_window: x11.Window = windowWMInfo.info.x11.window;

//     printf("x11_display: {x}\n", .{ @intFromPtr(x11_display) });
//     printf("x11_window: {x}\n", .{ x11_window });

//     const fromXlibWindow = wgpu.WGPUSurfaceSourceXlibWindow{
//         .chain = wgpu.WGPUChainedStruct{
//             .next = null,
//             .sType = wgpu.WGPUSType_SurfaceSourceXlibWindow
//         },
//         .display = x11_display,
//         .window = x11_window
//     };

//     var surfaceDescriptor = wgpu.WGPUSurfaceDescriptor{
//         .nextInChain = &fromXlibWindow,
//         .label = wgpu.WGPUStringView{
//             .data = null,
//             .length = 0
//         }
//     };

//     return wgpu.wgpuInstanceCreateSurface(instance, &surfaceDescriptor);
// }