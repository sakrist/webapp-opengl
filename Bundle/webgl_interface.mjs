
class WebGLInterface {
    constructor(options) {
        this.version = 1;
        /** @deprecated Use `wasmImports` instead */
        this.importObjects = () => this.wasmImports;
        this.textDecoder = new TextDecoder("utf-8");
        this.textEncoder = new TextEncoder(); // Only support utf-8
        this.GLctx = null;
        this._instance = null;
        
    }
    setInstance(instance) {
        this._instance = instance;
    }
    
    get wasmImports() {
        return {
            _setupContext: (address, byteCount) => {
                const buffer = this._instance.exports.memory.buffer.slice(address, address + byteCount);
                const string = this.textDecoder.decode(buffer);
                const canvas = document.getElementById(string);
                this.GLctx = canvas.getContext('webgl');
            },

            glViewport: (x, y, width, height) => {
                this.GLctx.viewport(x, y, width, height);
            },
            glClearColor: (r, g, b, a) => {
                this.GLctx.clearColor(r, g, b, a);
            },
            glClear: (mask) => {
                this.GLctx.clear(mask);
            },

            

        };
    }
}

export { WebGLInterface };