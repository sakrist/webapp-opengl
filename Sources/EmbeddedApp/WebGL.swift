

public typealias GLuint = UInt32
public typealias GLint = Int32
public typealias GLsizei = Int32
public typealias GLchar = Int8
public typealias GLenum = UInt32
public typealias GLboolean = UInt8

@_extern(wasm, module: "webgl", name: "_setupContext")
func _setupContext(address: Int, byteCount: Int) -> Void

public func setupGLContext(canvas: StaticString) {
    _setupContext(address: Int(bitPattern: canvas.utf8Start), byteCount: canvas.utf8CodeUnitCount)
}

@_extern(wasm, module: "webgl", name: "glViewport")
public func glViewport(_ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32)

@_extern(wasm, module: "webgl", name: "glClearColor")
public func glClearColor(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float)

@_extern(wasm, module: "webgl", name: "glClear")
public func glClear(_ mask: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glClearDepth")
public func glClearDepth(_ mask: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glClearStencil")
public func glClearStencil(_ mask: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glEnable")
public func glEnable(_ cap: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glDisable")
public func glDisable(_ cap: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glCreateProgram")
public func glCreateProgram() -> UInt32

@_extern(wasm, module: "webgl", name: "glCreateShader")
public func glCreateShader(_ type: Int32) -> UInt32

@_extern(wasm, module: "webgl", name: "glShaderSource")
public func glShaderSource(_ shader: GLuint, _ count: GLsizei, _ string: UnsafePointer<UnsafePointer<GLchar>?>!, _ length: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glCompileShader")
public func glCompileShader(_ shader: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glAttachShader")
public func glAttachShader(_ program: GLuint, _ shader: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glLinkProgram")
public func glLinkProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glUseProgram")
public func glUseProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glGetProgramiv")
public func glGetProgramiv(_ program: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLsizei>!) -> Void

@_extern(wasm, module: "webgl", name: "glGetProgramInfoLog")
public func glGetProgramInfoLog(_ program: GLuint, _ bufSize: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) -> Void

@_extern(wasm, module: "webgl", name: "glValidateProgram")
public func glValidateProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glGetShaderiv")
public func glGetShaderiv(_ shader: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glGetShaderInfoLog")
public func glGetShaderInfoLog(_ shader: GLuint, _ bufSize: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) -> Void

@_extern(wasm, module: "webgl", name: "glGetAttribLocation")
public func glGetAttribLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> Int32

@_extern(wasm, module: "webgl", name: "glGetUniformLocation")
public func glGetUniformLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> Int32

@_extern(wasm, module: "webgl", name: "glVertexAttribPointer")
public func glVertexAttribPointer(_ index: GLuint, _ size: GLint, _ type: GLenum, _ normalized: GLboolean, _ stride: GLsizei, _ pointer: UnsafeRawPointer!) -> Void

@_extern(wasm, module: "webgl", name: "glEnableVertexAttribArray")
public func glEnableVertexAttribArray(_ index: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glDrawArrays")
public func glDrawArrays(_ mode: GLint, _ first: GLint, _ count: GLsizei) -> Void

@_extern(wasm, module: "webgl", name: "glUniform1f")
public func glUniform1f(_ location: GLint, _ v0: Float) -> Void

@_extern(wasm, module: "webgl", name: "glUniform2f")
public func glUniform2f(_ location: GLint, _ v0: Float, _ v1: Float) -> Void

@_extern(wasm, module: "webgl", name: "glUniform3f")
public func glUniform3f(_ location: GLint, _ v0: Float, _ v1: Float, _ v2: Float) -> Void

@_extern(wasm, module: "webgl", name: "glUniform4f")
public func glUniform4f(_ location: GLint, _ v0: Float, _ v1: Float, _ v2: Float, _ v3: Float) -> Void

@_extern(wasm, module: "webgl", name: "glUniform1i")
public func glUniform1i(_ location: GLint, _ v0: GLint) -> Void

@_extern(wasm, module: "webgl", name: "glUniform2i")
public func glUniform2i(_ location: GLint, _ v0: GLint, _ v1: GLint) -> Void

@_extern(wasm, module: "webgl", name: "glUniform3i")
public func glUniform3i(_ location: GLint, _ v0: GLint, _ v1: GLint, _ v2: GLint) -> Void

@_extern(wasm, module: "webgl", name: "glUniform4i")
public func glUniform4i(_ location: GLint, _ v0: GLint, _ v1: GLint, _ v2: GLint, _ v3: GLint) -> Void

@_extern(wasm, module: "webgl", name: "glUniform1fv")
public func glUniform1fv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<Float>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform2fv")
public func glUniform2fv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<Float>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform3fv")
public func glUniform3fv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<Float>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform4fv")
public func glUniform4fv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<Float>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform1iv")
public func glUniform1iv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform2iv")
public func glUniform2iv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform3iv")
public func glUniform3iv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniform4iv")
public func glUniform4iv(_ location: GLint, _ count: GLsizei, _ value: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glUniformMatrix4fv")
public func glUniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: UnsafePointer<Float>!) -> Void

@_extern(wasm, module: "webgl", name: "glGenBuffers")
public func glGenBuffers(_ n: GLsizei, _ buffers: UnsafeMutablePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glBindBuffer")
public func glBindBuffer(_ target: GLenum, _ buffer: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glBufferData")
public func glBufferData(_ target: GLenum, _ size: GLsizei, _ data: UnsafeRawPointer!, _ usage: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glGenVertexArrays")
public func glGenVertexArrays(_ n: GLsizei, _ arrays: UnsafeMutablePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glBindVertexArray")
public func glBindVertexArray(_ array: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glDeleteVertexArrays")
public func glDeleteVertexArrays(_ n: GLsizei, _ arrays: UnsafePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glDeleteBuffers")
public func glDeleteBuffers(_ n: GLsizei, _ buffers: UnsafePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glBlendFunc")
public func glBlendFunc(_ sfactor: GLenum, _ dfactor: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glBlendEquation")
public func glBlendEquation(_ mode: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glBlendEquationSeparate")
public func glBlendEquationSeparate(_ modeRGB: GLenum, _ modeAlpha: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glBlendFuncSeparate")
public func glBlendFuncSeparate(_ srcRGB: GLenum, _ dstRGB: GLenum, _ srcAlpha: GLenum, _ dstAlpha: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glBlendColor")
public func glBlendColor(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) -> Void

@_extern(wasm, module: "webgl", name: "glGetError")
public func glGetError() -> GLenum

@_extern(wasm, module: "webgl", name: "glGetIntegerv")
public func glGetIntegerv(_ pname: GLenum, _ params: UnsafeMutablePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glActiveTexture")
public func glActiveTexture(_ texture: GLenum) -> Void

@_extern(wasm, module: "webgl", name: "glTexImage2D")
public func glTexImage2D(_ target: GLenum, _ level: GLint, _ internalformat: GLint, _ width: GLsizei, _ height: GLsizei, _ border: GLint, _ format: GLenum, _ type: GLenum, _ pixels: UnsafeRawPointer!) -> Void

@_extern(wasm, module: "webgl", name: "glGenTextures")
public func glGenTextures(_ n: GLsizei, _ textures: UnsafeMutablePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glBindTexture")
public func glBindTexture(_ target: GLenum, _ texture: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glTexParameteri")
public func glTexParameteri(_ target: GLenum, _ pname: GLenum, _ param: GLint) -> Void