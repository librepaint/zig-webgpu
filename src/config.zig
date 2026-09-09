pub const Backends = enum { 
    SDL, 
    GLFW
};

pub const DisplayServers = enum { 
    X11, 
    WAYLAND
};

pub const BACKEND_PATH = "/home/vexcess/Sync/Workspace/Microslop/zig-webgpu/wgpu-linux-x86_64-debug/include/webgpu/webgpu.h";
pub const WINDOW_BACKEND = Backends.GLFW;
pub const DISPLAY_SERVER = DisplayServers.X11;
