import { WASI, File, OpenFile, ConsoleStdout, PreopenDirectory } from 'https://esm.run/@bjorn3/browser_wasi_shim@0.3.0';

async function main(wasiEnabled = true) {
    // Fetch our Wasm File
    const response = await fetch(`./app.wasm`);
    const { Emscripten } = await import(`./emscripten.js`);
    const { SwiftRuntime } = await import(`./runtime.js`);
    const { WebGLInterface } = await import(`./webgl_interface.js`);
    // Create a new Swift Runtime instance to interact with JS and Swift
    const emscripten = new Emscripten();
    const swift = new SwiftRuntime();
    const webgl = new WebGLInterface({emscripten : emscripten});

    var imports = {
        javascript_kit: swift.wasmImports,
        webgl: webgl.wasmImports,
        env: emscripten.wasmImports,
    };
    var wasi = null;

    if (wasiEnabled) {
        // Create a new WASI system instance
        var wasi = new WASI(/* args */["app.wasm"], /* env */[], /* fd */[
            new OpenFile(new File([])), // stdin
            ConsoleStdout.lineBuffered((stdout) => {
                console.log(stdout);
            }),
            ConsoleStdout.lineBuffered((stderr) => {
                console.error(stderr);
            }),
            new PreopenDirectory("/", new Map()),
        ]);
        imports.wasi_snapshot_preview1 = wasi.wasiImport;
    }

    // Instantiate the WebAssembly file
    const { instance } = await WebAssembly.instantiateStreaming(response, imports);
    // Set the WebAssembly instance to the Swift Runtime
    emscripten.setInstance(instance);
    swift.setInstance(instance);
    webgl.setInstance(instance);
    // Start the WebAssembly WASI reactor instance
    if (wasi) {
        wasi.initialize(instance);
    }
    // Start Swift main function
    swift.main()
};

main(true);
