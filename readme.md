# zig-webgpu
Zig bindings for WebGPU. Will support both Dawn and WGPU backends. Currently only supports WGPU. Dawn in theory is more complete in its Linux support, but WGPU was easier for me to work with.

zig-webgpu will follow the WebGPU API according to MDN ([https://developer.mozilla.org/en-US/docs/Web/API/WebGPU_API](https://developer.mozilla.org/en-US/docs/Web/API/WebGPU_API)) as closely as possible, however there will necessarily be differences as the WebGPU API is for JavaScript rather than Zig which are fundamentally different languages. Currently, only a small subset of the native API surface has been wrapped in Zig to conform to the web API.

zig-webgpu was created primarily to act as the accelerated graphics backend for [LibrePaint 3D](https://github.com/librepaint/librepaint-3d) which is currently using CPU rasterization. The features that will get the highest priority of being implemented will be whatever I end up needing for LibrePaint and I'll continue to develop this project as needed for LibrePaint. That being said, after this initial release I won't be doing any major work on this project until late Spring since I have more urgent projects to complete. \- VExcess

## Issues
WGPU support for Linux is not stable yet. Some issues I've encountered are
1) device.adapterInfo() is not implemented in WGPU
2) WGPU surfaces are not compatible with SDL (but are compatible with GLFW)
3) Currently zig-webgpu only supports X11; I'll get to supporting Wayland and Windows at some point.

## Get Dawn
Build from source
```sh
# Install pkg-config on Ubuntu
sudo apt-get install pkg-config

# Clone the repo as "dawn"
git clone https://dawn.googlesource.com/dawn dawn && cd dawn

# Fetch dependencies (loosely equivalent to gclient sync)
python3 tools/fetch_dawn_dependencies.py

sudo apt-get install libxrandr-dev libxinerama-dev libxcursor-dev mesa-common-dev libx11-xcb-dev pkg-config

mkdir -p out/Debug
cd out/Debug
cmake -GNinja ../..
ninja # or autoninja
```

## Get WGPU
Download release:  
[https://github.com/gfx-rs/wgpu-native/releases](https://github.com/gfx-rs/wgpu-native/releases)

## Run Example
Note: You may need to changes paths in the build.json5 depending on where you "install" wgpu to.
1) Install jvbuild ([https://github.com/vExcess/jvbuild](https://github.com/vExcess/jvbuild))
2) Install zig dependencies `jvbuild install`
3) Run example `jvbuild run example`