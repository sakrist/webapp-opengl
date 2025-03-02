import { WASI, File, OpenFile, ConsoleStdout, PreopenDirectory } from 'https://esm.run/@bjorn3/browser_wasi_shim@0.3.0';

async function main(wasiEnabled = true) {
    // Fetch our Wasm File
    const response = await fetch(`./app.wasm`);
    const { SwiftRuntime } = await import(`./index.mjs`);
    // Create a new Swift Runtime instance to interact with JS and Swift
    const swift = new SwiftRuntime();

    var imports = {
        javascript_kit: swift.wasmImports,
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
    swift.setInstance(instance);
    // Start the WebAssembly WASI reactor instance
    if (wasi) {
        wasi.initialize(instance);
    }
    // Start Swift main function
    swift.main()
};

main(true);
