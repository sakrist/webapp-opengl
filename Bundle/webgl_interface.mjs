
var webgl_enable_OES_vertex_array_object = ctx => {
    // Extension available in WebGL 1 from Firefox 25 and WebKit 536.28/desktop Safari 6.0.3 onwards. Core feature in WebGL 2.
    var ext = ctx.getExtension("OES_vertex_array_object");
    if (ext) {
      ctx["createVertexArray"] = () => ext["createVertexArrayOES"]();
      ctx["deleteVertexArray"] = vao => ext["deleteVertexArrayOES"](vao);
      ctx["bindVertexArray"] = vao => ext["bindVertexArrayOES"](vao);
      ctx["isVertexArray"] = vao => ext["isVertexArrayOES"](vao);
      return 1;
    }
  };
  
  var webgl_enable_WEBGL_draw_buffers = ctx => {
    // Extension available in WebGL 1 from Firefox 28 onwards. Core feature in WebGL 2.
    var ext = ctx.getExtension("WEBGL_draw_buffers");
    if (ext) {
      ctx["drawBuffers"] = (n, bufs) => ext["drawBuffersWEBGL"](n, bufs);
      return 1;
    }
  };

  var getEmscriptenSupportedExtensions = ctx => {
    // Restrict the list of advertised extensions to those that we actually
    // support.
    var supportedExtensions = [ // WebGL 1 extensions
    "ANGLE_instanced_arrays", "EXT_blend_minmax", "EXT_disjoint_timer_query", "EXT_frag_depth", "EXT_shader_texture_lod", "EXT_sRGB", "OES_element_index_uint", "OES_fbo_render_mipmap", "OES_standard_derivatives", "OES_texture_float", "OES_texture_half_float", "OES_texture_half_float_linear", "OES_vertex_array_object", "WEBGL_color_buffer_float", "WEBGL_depth_texture", "WEBGL_draw_buffers", // WebGL 2 extensions
    "EXT_color_buffer_float", "EXT_conservative_depth", "EXT_disjoint_timer_query_webgl2", "EXT_texture_norm16", "NV_shader_noperspective_interpolation", "WEBGL_clip_cull_distance", // WebGL 1 and WebGL 2 extensions
    "EXT_clip_control", "EXT_color_buffer_half_float", "EXT_depth_clamp", "EXT_float_blend", "EXT_polygon_offset_clamp", "EXT_texture_compression_bptc", "EXT_texture_compression_rgtc", "EXT_texture_filter_anisotropic", "KHR_parallel_shader_compile", "OES_texture_float_linear", "WEBGL_blend_func_extended", "WEBGL_compressed_texture_astc", "WEBGL_compressed_texture_etc", "WEBGL_compressed_texture_etc1", "WEBGL_compressed_texture_s3tc", "WEBGL_compressed_texture_s3tc_srgb", "WEBGL_debug_renderer_info", "WEBGL_debug_shaders", "WEBGL_lose_context", "WEBGL_multi_draw", "WEBGL_polygon_mode" ];
    // .getSupportedExtensions() can return null if context is lost, so coerce to empty array.
    return (ctx.getSupportedExtensions() || []).filter(ext => supportedExtensions.includes(ext));
  };

class WebGLInterface {
    constructor(options) {
        this.version = 1;
        /** @deprecated Use `wasmImports` instead */
        this.importObjects = () => this.wasmImports;
        this.textDecoder = new TextDecoder("utf-8");
        this.textEncoder = new TextEncoder(); // Only support utf-8
        this.GLctx = null;
        this._instance = null;
        this.counter = 1;
        this.buffers = [];
        this.mappedBuffers = {};
        this.programs = [];
        this.framebuffers = [];
        this.renderbuffers = [];
        this.textures = [];
        this.uniforms = [];
        this.shaders = [];
        this.vaos = [];
        this.contexts = {};
        this.programInfos = {};

        this.emscripten_shaders_hack = true;
        
    }
    setInstance(instance) {
        this._instance = instance;
    }
    
    assert(condition, text) {
        if (!condition) throw text;
    }
    
    getNewId(table) {
        var ret = this.counter++;
        for (var i = table.length; i < ret; i++) {
            table[i] = null;
        }
        return ret;
    }

    getArray(ptr, arr, n) {
        return new arr(this._instance.exports.memory.buffer, ptr, n);
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

    _glGenObject(n, buffers, createFunction, objectTable, functionName) {
        for (var i = 0; i < n; i++) {
            var buffer = this.GLctx[createFunction]();
            var id = buffer && this.getNewId(objectTable);
            if (buffer) {
                buffer.name = id;
                objectTable[id] = buffer;
            } else {
                console.error("GL_INVALID_OPERATION");
                this.GLctx.recordError(0x0502 /* GL_INVALID_OPERATION */);
    
                alert('GL_INVALID_OPERATION in ' + functionName + ': GLctx.' + createFunction + ' returned null - most likely GL context is lost!');
            }
            this.getArray(buffers + i * 4, Int32Array, 1)[0] = id;
        }
    }

    validateGLObjectID (objectHandleArray, objectID, callerFunctionName, objectReadableType) {
        if (objectID != 0) {
            if (objectHandleArray[objectID] === null) {
                console.error(callerFunctionName + ' called with an already deleted ' + objectReadableType + ' ID ' + objectID + '!');
            } else if (!objectHandleArray[objectID]) {
                console.error(callerFunctionName + ' called with an invalid ' + objectReadableType + ' ID ' + objectID + '!');
            }
        }
    }
    getSource (shader, count, string, length) {
        var source = '';
        for (var i = 0; i < count; ++i) {
            var len = length == 0 ? undefined : this.getArray(length + i * 4, Uint32Array, 1)[0];
            source += this.UTF8ToString(this.getArray(string + i * 4, Uint32Array, 1)[0], len);
        }
        return source;
    }
    populateUniformTable (program) {
        this.validateGLObjectID(this.programs, program, 'populateUniformTable', 'program');
        var p = this.programs[program];
        var ptable = this.programInfos[program] = {
            uniforms: {},
            maxUniformLength: 0, // This is eagerly computed below, since we already enumerate all uniforms anyway.
            maxAttributeLength: -1, // This is lazily computed and cached, computed when/if first asked, "-1" meaning not computed yet.
            maxUniformBlockNameLength: -1 // Lazily computed as well
        };

        var utable = ptable.uniforms;
        // A program's uniform table maps the string name of an uniform to an integer location of that uniform.
        // The global this.uniforms map maps integer locations to WebGLUniformLocations.
        var numUniforms = this.GLctx.getProgramParameter(p, 0x8B86/*GL_ACTIVE_UNIFORMS*/);
        for (var i = 0; i < numUniforms; ++i) {
            var u = this.GLctx.getActiveUniform(p, i);

            var name = u.name;
            ptable.maxUniformLength = Math.max(ptable.maxUniformLength, name.length + 1);

            // If we are dealing with an array, e.g. vec4 foo[3], strip off the array index part to canonicalize that "foo", "foo[]",
            // and "foo[0]" will mean the same. Loop below will populate foo[1] and foo[2].
            if (name.slice(-1) == ']') {
                name = name.slice(0, name.lastIndexOf('['));
            }

            // Optimize memory usage slightly: If we have an array of uniforms, e.g. 'vec3 colors[3];', then
            // only store the string 'colors' in utable, and 'colors[0]', 'colors[1]' and 'colors[2]' will be parsed as 'colors'+i.
            // Note that for the this.uniforms table, we still need to fetch the all WebGLUniformLocations for all the indices.
            var loc = this.GLctx.getUniformLocation(p, name);
            if (loc) {
                var id = this.getNewId(this.uniforms);
                utable[name] = [u.size, id];
                this.uniforms[id] = loc;

                for (var j = 1; j < u.size; ++j) {
                    var n = name + '[' + j + ']';
                    loc = this.GLctx.getUniformLocation(p, n);
                    id = this.getNewId(this.uniforms);

                    this.GLctx.uniforms[id] = loc;
                }
            }
        }
    }

    get wasmImports() {
        return {
            _setupContext: (address, byteCount) => {
                const buffer = this._instance.exports.memory.buffer.slice(address, address + byteCount);
                const string = this.textDecoder.decode(buffer);
                const canvas = document.getElementById(string);
                
                var contextAttributes = {
                    alpha: true,
                    antialias: true,
                    depth: true,
                    enableExtensionsByDefault: true,
                    failIfMajorPerformanceCaveat: false,
                    powerPreference: "default",
                    premultipliedAlpha: true,
                    preserveDrawingBuffer: false,
                    majorVersion: 1,
                    minorVersion: 0,
                    stencil: true,
                    desynchronized: false,
                    xrCompatible: false
                };

                this.GLctx = canvas.getContext("webgl2", contextAttributes);
                webgl_enable_OES_vertex_array_object(this.GLctx);
                webgl_enable_WEBGL_draw_buffers(this.GLctx);

                getEmscriptenSupportedExtensions(this.GLctx).forEach(ext => {
                // WEBGL_lose_context, WEBGL_debug_renderer_info and WEBGL_debug_shaders
                // are not enabled by default.
                if (!ext.includes("lose_context") && !ext.includes("debug")) {
                    // Call .getExtension() to enable that extension permanently.
                    this.GLctx.getExtension(ext);
                }
                });
                
                if (!this.GLctx) {
                    throw new Error('WebGL 2 not available');
                }
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
            
/// https://github.com/opendevleague/bunkernz/blob/1fbc444970fa6bf4e5c878fd361c74457c12997d/client/web/gl.js#L398
            glClearDepthf: (depth) => {
                this.GLctx.clearDepth(depth);
            },
            glClearStencil:(s) => {
                this.GLctx.clearColorStencil(s);
            },
            glColorMask: (red, green, blue, alpha) => {
                this.GLctx.colorMask(red, green, blue, alpha);
            },
            glScissor: (x, y, w, h) => {
                this.GLctx.scissor(x, y, w, h);
            },
            glGenTextures: (n, textures) => {
                this._glGenObject(n, textures, "createTexture", this.textures, "glGenTextures")
            },
            glActiveTexture: (texture) => {
                this.GLctx.activeTexture(texture)
            },
            glBindTexture: (target, texture) => {
                this.validateGLObjectID(this.textures, texture, 'glBindTexture', 'texture');
                this.GLctx.bindTexture(target, this.textures[texture]);
            },
            glTexImage2D: (target, level, internalFormat, width, height, border, format, type, pixels) => {
                this.GLctx.texImage2D(target, level, internalFormat, width, height, border, format, type,
                    pixels ? this.getArray(pixels, Uint8Array, texture_size(internalFormat, width, height)) : null);
            },
            glTexSubImage2D: (target, level, xoffset, yoffset, width, height, format, type, pixels) => {
                this.GLctx.texSubImage2D(target, level, xoffset, yoffset, width, height, format, type,
                    pixels ? this.getArray(pixels, Uint8Array, texture_size(format, width, height)) : null);
            },
            glTexParameteri: (target, pname, param) => {
                this.GLctx.texParameteri(target, pname, param);
            },
            glUniform1fv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform1fv', 'location');
                assert((value & 3) == 0, 'Pointer to float data passed to glUniform1fv must be aligned to four bytes!');
                var view = this.getArray(value, Float32Array, 1 * count);
                this.GLctx.uniform1fv(this.uniforms[location], view);
            },
            glUniform2fv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform2fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to float data passed to glUniform2fv must be aligned to four bytes!');
                var view = this.getArray(value, Float32Array, 2 * count);
                this.GLctx.uniform2fv(this.uniforms[location], view);
            },
            glUniform3fv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform3fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to float data passed to glUniform3fv must be aligned to four bytes!');
                var view = this.getArray(value, Float32Array, 4 * count);
                this.GLctx.uniform3fv(this.uniforms[location], view);
            },
            glUniform4fv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform4fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to float data passed to glUniform4fv must be aligned to four bytes!');
                var view = this.getArray(value, Float32Array, 4 * count);
                this.GLctx.uniform4fv(this.uniforms[location], view);
            },
            glUniform1iv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform1fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to i32 data passed to glUniform1iv must be aligned to four bytes!');
                var view = this.getArray(value, Int32Array, 1 * count);
                this.GLctx.uniform1iv(this.uniforms[location], view);
            },
            glUniform2iv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform2fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to i32 data passed to glUniform2iv must be aligned to four bytes!');
                var view = this.getArray(value, Int32Array, 2 * count);
                this.GLctx.uniform2iv(this.uniforms[location], view);
            },
            glUniform3iv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform3fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to i32 data passed to glUniform3iv must be aligned to four bytes!');
                var view = this.getArray(value, Int32Array, 3 * count);
                this.GLctx.uniform3iv(this.uniforms[location], view);
            },
            glUniform4iv: (location, count, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform4fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to i32 data passed to glUniform4iv must be aligned to four bytes!');
                var view = this.getArray(value, Int32Array, 4 * count);
                this.GLctx.uniform4iv(this.uniforms[location], view);
            },
            glBlendFunc: (sfactor, dfactor) => {
                this.GLctx.blendFunc(sfactor, dfactor);
            },
            glBlendEquationSeparate: (modeRGB, modeAlpha) => {
                this.GLctx.blendEquationSeparate(modeRGB, modeAlpha);
            },
            glDisable: (cap) => {
                this.GLctx.disable(cap);
            },
            glDrawElements: (mode, count, type, indices) => {
                this.GLctx.drawElements(mode, count, type, indices);
            },
            glGetIntegerv: (name_, p) => {
                _webglGet(name_, p, 'EM_FUNC_SIG_PARAM_I');
            },
            glUniform1f: (location, v0) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform1f', 'location');
                this.GLctx.uniform1f(this.uniforms[location], v0);
            },
            glUniform1i: (location, v0) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniform1i', 'location');
                this.GLctx.uniform1i(this.uniforms[location], v0);
            },
            glGetAttribLocation: (program, name) => {
                return this.GLctx.getAttribLocation(this.programs[program], this.UTF8ToString(name));
            },
            glEnableVertexAttribArray: (index) => {
                this.GLctx.enableVertexAttribArray(index);
            },
            glDisableVertexAttribArray: (index) => {
                this.GLctx.disableVertexAttribArray(index);
            },
            glVertexAttribPointer: (index, size, type, normalized, stride, ptr) => {
                this.GLctx.vertexAttribPointer(index, size, type, !!normalized, stride, ptr);
            },
            glGetUniformLocation: (program, name) => {
                this.validateGLObjectID(this.programs, program, 'glGetUniformLocation', 'program');
                name = this.UTF8ToString(name);
                var arrayIndex = 0;
                // If user passed an array accessor "[index]", parse the array index off the accessor.
                if (name[name.length - 1] == ']') {
                    var leftBrace = name.lastIndexOf('[');
                    arrayIndex = name[leftBrace + 1] != ']' ? parseInt(name.slice(leftBrace + 1)) : 0; // "index]", parseInt will ignore the ']' at the end; but treat "foo[]" as "foo[0]"
                    name = name.slice(0, leftBrace);
                }
        
                var uniformInfo = this.programInfos[program] && this.programInfos[program].uniforms[name]; // returns pair [ dimension_of_uniform_array, uniform_location ]
                if (uniformInfo && arrayIndex >= 0 && arrayIndex < uniformInfo[0]) { // Check if user asked for an out-of-bounds element, i.e. for 'vec4 colors[3];' user could ask for 'colors[10]' which should return -1.
                    return uniformInfo[1] + arrayIndex;
                } else {
                    return -1;
                }
            },
            glUniformMatrix4fv: (location, count, transpose, value) => {
                this.validateGLObjectID(this.uniforms, location, 'glUniformMatrix4fv', 'location');
                this.assert((value & 3) == 0, 'Pointer to float data passed to glUniformMatrix4fv must be aligned to four bytes!');
                var view = this.getArray(value, Float32Array, 16);
                this.GLctx.uniformMatrix4fv(this.uniforms[location], !!transpose, view);
            },
            glUseProgram: (program) => {
                this.validateGLObjectID(this.programs, program, 'glUseProgram', 'program');
                this.GLctx.useProgram(this.programs[program]);
            },
            glValidateProgram: (program) => {
                this.GLctx.validateProgram(this.programs[program]);
            },
            glIsProgram: (program) => {
                program = this.programs[program];
                if (!program) return 0;
                return this.GLctx.isProgram(program);
            },
            glGenVertexArrays: (n, arrays) => {
                this._glGenObject(n, arrays, 'createVertexArray', this.vaos, 'glGenVertexArrays');
            },
            glGenFramebuffers: (n, ids) => {
                this._glGenObject(n, ids, 'createFramebuffer', this.framebuffers, 'glGenFramebuffers');
            },
            glBindVertexArray: (vao) => {
                this.GLctx.bindVertexArray(this.vaos[vao]);
            },
            glBindFramebuffer: (target, framebuffer) => {
                this.validateGLObjectID(this.framebuffers, framebuffer, 'glBindFramebuffer', 'framebuffer');
        
                this.GLctx.bindFramebuffer(target, this.framebuffers[framebuffer]);
            },
        
            glGenBuffers: (n, buffers) => {
                this._glGenObject(n, buffers, 'createBuffer', this.buffers, 'glGenBuffers');
            },
            glBindBuffer: (target, buffer) => {
                this.validateGLObjectID(this.buffers, buffer, 'glBindBuffer', 'buffer');
                this.GLctx.bindBuffer(target, this.buffers[buffer]);
            },
            glBufferData: (target, size, data, usage) => {
                this.GLctx.bufferData(target, data ? this.getArray(data, Uint8Array, size) : size, usage);
            },
            glBufferSubData: (target, offset, size, data) => {
                this.GLctx.bufferSubData(target, offset, data ? this.getArray(data, Uint8Array, size) : size);
            },
            glEnable: (cap) => {
                this.GLctx.enable(cap);
            },
            glDepthFunc: (func) => {
                this.GLctx.depthFunc(func);
            },
            glBlendFuncSeparate: (sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha) => {
                this.GLctx.blendFuncSeparate(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha);
            },
            glDrawArrays: (mode, first, count) => {
                this.GLctx.drawArrays(mode, first, count);
            },
            glCreateProgram:() => {
                var id = this.getNewId(this.programs);
                var program = this.GLctx.createProgram();
                program.name = id;
                this.programs[id] = program;
                return id;
            },
            glAttachShader: (program, shader) => {
                this.validateGLObjectID(this.programs, program, 'glAttachShader', 'program');
                this.validateGLObjectID(this.shaders, shader, 'glAttachShader', 'shader');
                this.GLctx.attachShader(this.programs[program], this.shaders[shader]);
            },
            glLinkProgram: (program) => {
                this.validateGLObjectID(this.programs, program, 'glLinkProgram', 'program');
                this.GLctx.linkProgram(this.programs[program]);
                this.populateUniformTable(program);
            },
            glPixelStorei: (pname, param) => {
                this.GLctx.pixelStorei(pname, param);
            },
            glFramebufferTexture2D: (target, attachment, textarget, texture, level) => {
                this.validateGLObjectID(this.textures, texture, 'glFramebufferTexture2D', 'texture');
                this.GLctx.framebufferTexture2D(target, attachment, textarget, this.textures[texture], level);
            },
            glGetProgramiv: (program, pname, p) => {
                this.assert(p);
                this.validateGLObjectID(this.programs, program, 'glGetProgramiv', 'program');
                if (program >= this.counter) {
                    console.error("GL_INVALID_VALUE in glGetProgramiv");
                    return;
                }
                var ptable = this.programInfos[program];
                if (!ptable) {
                    console.error('GL_INVALID_OPERATION in glGetProgramiv(program=' + program + ', pname=' + pname + ', p=0x' + p.toString(16) + '): The specified GL object name does not refer to a program object!');
                    return;
                }
                if (pname == 0x8B84) { // GL_INFO_LOG_LENGTH
                    var log = this.GLctx.getProgramInfoLog(this.programs[program]);
                    this.assert(log !== null);
        
                    this.getArray(p, Int32Array, 1)[0] = log.length + 1;
                } else if (pname == 0x8B87 /* GL_ACTIVE_UNIFORM_MAX_LENGTH */) {
                    console.error("unsupported operation");
                    return;
                } else if (pname == 0x8B8A /* GL_ACTIVE_ATTRIBUTE_MAX_LENGTH */) {
                    console.error("unsupported operation");
                    return;
                } else if (pname == 0x8A35 /* GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH */) {
                    console.error("unsupported operation");
                    return;
                } else {
                    this.getArray(p, Int32Array, 1)[0] = this.GLctx.getProgramParameter(this.programs[program], pname);
                }
            },
            glCreateShader: (shaderType) => {
                var id = this.getNewId(this.shaders);
                this.shaders[id] = this.GLctx.createShader(shaderType);
                return id;
            },
            glStencilFuncSeparate: (face, func, ref_, mask) => {
                this.GLctx.stencilFuncSeparate(face, func, ref_, mask);
            },
            glStencilMaskSeparate: (face, mask) => {
                this.GLctx.stencilMaskSeparate(face, mask);
            },
            glStencilOpSeparate: (face, fail, zfail, zpass) => {
                this.GLctx.stencilOpSeparate(face, fail, zfail, zpass);
            },
            glFrontFace: (mode) => {
                this.GLctx.frontFace(mode);
            },
            glCullFace: (mode) => {
                this.GLctx.cullFace(mode);
            },
            glShaderSource: (shader, count, string, length) => {
                this.validateGLObjectID(this.shaders, shader, 'glShaderSource', 'shader');
                var source = this.getSource(shader, count, string, length);
        
                // https://github.com/emscripten-core/emscripten/blob/incoming/src/library_webgl.js#L2708
                if (this.emscripten_shaders_hack) {
                    source = source.replace(/#extension GL_OES_standard_derivatives : enable/g, "");
                    source = source.replace(/#extension GL_EXT_shader_texture_lod : enable/g, '');
                    var prelude = '';
                    if (source.indexOf('gl_FragColor') != -1) {
                        prelude += 'out mediump vec4 GL_FragColor;\n';
                        source = source.replace(/gl_FragColor/g, 'GL_FragColor');
                    }
                    if (source.indexOf('attribute') != -1) {
                        source = source.replace(/attribute/g, 'in');
                        source = source.replace(/varying/g, 'out');
                    } else {
                        source = source.replace(/varying/g, 'in');
                    }
        
                    source = source.replace(/textureCubeLodEXT/g, 'textureCubeLod');
                    source = source.replace(/texture2DLodEXT/g, 'texture2DLod');
                    source = source.replace(/texture2DProjLodEXT/g, 'texture2DProjLod');
                    source = source.replace(/texture2DGradEXT/g, 'texture2DGrad');
                    source = source.replace(/texture2DProjGradEXT/g, 'texture2DProjGrad');
                    source = source.replace(/textureCubeGradEXT/g, 'textureCubeGrad');
        
                    source = source.replace(/textureCube/g, 'texture');
                    source = source.replace(/texture1D/g, 'texture');
                    source = source.replace(/texture2D/g, 'texture');
                    source = source.replace(/texture3D/g, 'texture');
                    source = source.replace(/#version 100/g, '#version 300 es\n' + prelude);
                }
        
                this.GLctx.shaderSource(this.shaders[shader], source);
            },
            glGetProgramInfoLog: (program, maxLength, length, infoLog) => {
                this.validateGLObjectID(this.programs, program, 'glGetProgramInfoLog', 'program');
                var log = this.GLctx.getProgramInfoLog(this.programs[program]);
                this.assert(log !== null);
                let array = this.getArray(infoLog, Uint8Array, maxLength);
                for (var i = 0; i < maxLength; i++) {
                    array[i] = log.charCodeAt(i);
                }
            },
            glCompileShader: (shader, count, string, length) => {
                this.validateGLObjectID(this.shaders, shader, 'glCompileShader', 'shader');
                this.GLctx.compileShader(this.shaders[shader]);
            },
            glGetShaderiv: (shader, pname, p) => {
                this.assert(p);
                this.validateGLObjectID(this.shaders, shader, 'glGetShaderiv', 'shader');
                if (pname == 0x8B84) { // GL_INFO_LOG_LENGTH
                    var log = this.GLctx.getShaderInfoLog(this.shaders[shader]);
                    this.assert(log !== null);
        
                    this.getArray(p, Int32Array, 1)[0] = log.length + 1;
        
                } else if (pname == 0x8B88) { // GL_SHADER_SOURCE_LENGTH
                    var source = this.GLctx.getShaderSource(this.shaders[shader]);
                    var sourceLength = (source === null || source.length == 0) ? 0 : source.length + 1;
                    this.getArray(p, Int32Array, 1)[0] = sourceLength;
                } else {
                    this.getArray(p, Int32Array, 1)[0] = this.GLctx.getShaderParameter(this.shaders[shader], pname);
                }
            },
            glGetShaderInfoLog: (shader, maxLength, length, infoLog) => {
                this.validateGLObjectID(this.shaders, shader, 'glGetShaderInfoLog', 'shader');
                var log = this.GLctx.getShaderInfoLog(this.shaders[shader]);
                this.assert(log !== null);
                let array = this.getArray(infoLog, Uint8Array, maxLength);
                for (var i = 0; i < maxLength; i++) {
                    array[i] = log.charCodeAt(i);
                }
            },
            glVertexAttribDivisor: (index, divisor) => {
                this.GLctx.vertexAttribDivisor(index, divisor);
            },
            glDrawArraysInstanced: (mode, first, count, primcount) => {
                this.GLctx.drawArraysInstanced(mode, first, count, primcount);
            },
            glDrawElementsInstanced: (mode, count, type, indices, primcount) => {
                this.GLctx.drawElementsInstanced(mode, count, type, indices, primcount);
            },
            glDeleteShader: (shader) => { this.GLctx.deleteShader(shader) },
            glDeleteBuffers: (n, buffers) => {
                for (var i = 0; i < n; i++) {
                    var id = this.getArray(buffers + i * 4, Uint32Array, 1)[0];
                    var buffer = this.buffers[id];
        
                    // From spec: "glDeleteBuffers silently ignores 0's and names that do not
                    // correspond to existing buffer objects."
                    if (!buffer) continue;
        
                    this.GLctx.deleteBuffer(buffer);
                    buffer.name = 0;
                    this.buffers[id] = null;
                }
            },
            glDeleteFramebuffers: (n, buffers) => {
                for (var i = 0; i < n; i++) {
                    var id = this.getArray(buffers + i * 4, Uint32Array, 1)[0];
                    var buffer = this.framebuffers[id];
        
                    // From spec: "glDeleteFrameBuffers silently ignores 0's and names that do not
                    // correspond to existing buffer objects."
                    if (!buffer) continue;
        
                    this.GLctx.deleteFramebuffer(buffer);
                    buffer.name = 0;
                    this.framebuffers[id] = null;
                }
            },
            glDeleteTextures: (n, textures) => {
                for (var i = 0; i < n; i++) {
                    var id = this.getArray(textures + i * 4, Uint32Array, 1)[0];
                    var texture = this.textures[id];
                    if (!texture) continue; // GL spec: "glDeleteTextures silently ignores 0s and names that do not correspond to existing textures".
                    this.GLctx.deleteTexture(texture);
                    texture.name = 0;
                    this.textures[id] = null;
                }
            },


        };
    }
}

export { WebGLInterface };