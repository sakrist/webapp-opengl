
Sample with 2 types of libc.
One is coming from WASI and another one is from Embedded + emscripten SDK.

## Build

To build this project you need:
- [Swift 6.1 Development Snapshot](https://www.swift.org/download/)
- [SwiftWasm Toolchain](https://book.swiftwasm.org/getting-started/setup.html)  
- [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html)

>[!IMPORTANT]
> Versions of both swift toolchains are hardcoded in `build_embedded_emsdk` and `build_wasi` functions of build.sh. Update to your version.

Option 1

Uses Swift Embedded and emsdk. Escripten SDK will be installed by script next to the script. 
```bash
./build.sh emsdk
```

Option 2

Uses SwiftWasm with WASI.
```bash
./build.sh wasi
```

First option produces smaller wasm file but has limited feature set.

Serve via
```bash
./build.sh serve
```


