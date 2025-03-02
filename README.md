
Sample with 2 types of libc.
One is coming from WASI and another one is from emscripten SDK.

## Build

To build this project you need:
- [Swift 6.1 Development Snapshot](https://www.swift.org/download/)
- [SwiftWasm Toolchain](https://book.swiftwasm.org/getting-started/setup.html)  
- [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html)

Option 1

To use swift embedded and emsdk. Escripten SDK will be installed by script.
```bash
./build.sh emsdk
```

Option 2

To use swiftwasm WASI.
```bash
./build.sh wasi
```

Serve via
```bash
./build.sh serve
```



>[!IMPORTANT]
> Versions of both swift toolchains are hardcoded in `build_embedded_emsdk` and `build_wasi` functions of build.sh. Update to your version.

