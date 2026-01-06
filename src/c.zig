// Dawn: /zig-webgpu/dawn/out/Debug/gen/include/dawn/webgpu.h
// wgpu: /zig-webgpu/wgpu-linux-x86_64-debug/include/webgpu/webgpu.h
const cImports = @cImport({
    // @cInclude("SDL2/SDL.h");
    // @cInclude("SDL2/SDL_syswm.h");
    // @cInclude("SDL2/SDL_version.h");
    @cInclude("GLFW/glfw3.h");
    @cInclude("X11/Xlib.h");
    @cInclude("/home/vexcess/Sync/Workspace/zig-webgpu/wgpu-linux-x86_64-debug/include/webgpu/webgpu.h");
});

pub const wgpu = cImports;
pub const glfw = cImports;
pub const x11 = cImports;