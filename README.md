
Sample with 2 types of libc.
One is coming from WASI and another one is from Embedded + emscripten SDK.

## Build

To build this project you need:
- [Swift 6.1 release](https://www.swift.org/download/)
- [SwiftWasm SDK](https://book.swiftwasm.org/getting-started/setup.html#installation---latest-release-swift-61)  
- [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html)

>[!IMPORTANT]
> Versions of both swift toolchains are hardcoded in `build_embedded_emsdk` and `build_wasi` functions of build.sh. Update to your version.

Option 1 - try this

Uses Swift Embedded and emsdk. Escripten SDK will be installed by script next to the script. 
```bash
./build.sh emsdk
```

Option 2

Uses SwiftWasm with WASI.
```bash
./build.sh wasi
```

First option produces smaller wasm file.

Serve via
```bash
./build.sh serve
```

To try game go to blog post [here](https://sakrist.com/posts/swift-and-webassembly-for-a-browser/#flappy-bird-clone)

<img src="Screenshot.jpg" width="40%">


## License 
* emsdk - MIT, and [this](https://github.com/emscripten-core/emscripten/blob/main/LICENSE)
* JavaScriptKit - [MIT](https://github.com/swiftwasm/JavaScriptKit/blob/main/LICENSE)
* bunkernz - [MIT](https://github.com/opendevleague/bunkernz/blob/master/LICENSE)
