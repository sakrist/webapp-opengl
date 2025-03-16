
// some of the missing functions that are needed by libc or other libraries

class Emscripten {
    constructor(options) {
        this.textDecoder = new TextDecoder("utf-8");
        this.textEncoder = new TextEncoder(); // Only support utf-8
        this._instance = null;
    }
    setInstance(instance) {
        this._instance = instance;
    }

    getArray(ptr, arr, n) {
        return new arr(this._instance.exports.memory.buffer, ptr, n);
    }

    getSource (shader, count, string, length) {
        var source = '';
        for (var i = 0; i < count; ++i) {
            var len = length == 0 ? undefined : this.getArray(length + i * 4, Uint32Array, 1)[0];
            source += this.UTF8ToString(this.getArray(string + i * 4, Uint32Array, 1)[0], len);
        }
        return source;
    }

    UTF8ToString(ptr, maxBytesToRead) {
        let u8Array = new Uint8Array(this._instance.exports.memory.buffer, ptr);
    
        var idx = 0;
        var endIdx = idx + maxBytesToRead;
    
        var str = '';
        while (!(idx >= endIdx)) {
            // For UTF8 byte structure, see:
            // http://en.wikipedia.org/wiki/UTF-8#Description
            // https://www.ietf.org/rfc/rfc2279.txt
            // https://tools.ietf.org/html/rfc3629
            var u0 = u8Array[idx++];
    
            // If not building with TextDecoder enabled, we don't know the string length, so scan for \0 byte.
            // If building with TextDecoder, we know exactly at what byte index the string ends, so checking for nulls here would be redundant.
            if (!u0) return str;
    
            if (!(u0 & 0x80)) { str += String.fromCharCode(u0); continue; }
            var u1 = u8Array[idx++] & 63;
            if ((u0 & 0xE0) == 0xC0) { str += String.fromCharCode(((u0 & 31) << 6) | u1); continue; }
            var u2 = u8Array[idx++] & 63;
            if ((u0 & 0xF0) == 0xE0) {
                u0 = ((u0 & 15) << 12) | (u1 << 6) | u2;
            } else {
    
                if ((u0 & 0xF8) != 0xF0) console.warn('Invalid UTF-8 leading byte 0x' + u0.toString(16) + ' encountered when deserializing a UTF-8 string on the asm.js/wasm heap to a JS string!');
    
                u0 = ((u0 & 7) << 18) | (u1 << 12) | (u2 << 6) | (u8Array[idx++] & 63);
            }
    
            if (u0 < 0x10000) {
                str += String.fromCharCode(u0);
            } else {
                var ch = u0 - 0x10000;
                str += String.fromCharCode(0xD800 | (ch >> 10), 0xDC00 | (ch & 0x3FF));
            }
        }
    
        return str;
    }

    get wasmImports() {
        return {
            emscripten_date_now: () => {
                return Date.now();
            }
        }
    }
};

export { Emscripten };