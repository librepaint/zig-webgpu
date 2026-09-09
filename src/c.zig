const config = @import("./config.zig");

// Dawn: /zig-webgpu/dawn/out/Debug/gen/include/dawn/webgpu.h
// wgpu: /zig-webgpu/wgpu-linux-x86_64-debug/include/webgpu/webgpu.h
const cImports = @cImport({
    if (config.WINDOW_BACKEND == config.Backends.SDL) {
        @cInclude("SDL2/SDL.h");
        @cInclude("SDL2/SDL_syswm.h");
        @cInclude("SDL2/SDL_version.h");
    } else if (config.WINDOW_BACKEND == config.Backends.GLFW) {
        @cInclude("GLFW/glfw3.h");
    }
    if (config.DISPLAY_SERVER == config.DisplayServers.X11) {
        @cInclude("X11/Xlib.h");
    } else {
        @compileError("Only X11 is currently supported");
    }
    @cInclude(config.BACKEND_PATH);
});

pub const wgpu = cImports;
pub const glfw = cImports;
pub const x11 = cImports;