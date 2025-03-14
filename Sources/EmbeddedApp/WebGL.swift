
public typealias GLuint = UInt32
public typealias GLint = Int32
public typealias GLsizei = Int32
public typealias GLchar = Int8
public typealias GLenum = UInt32
public typealias GLboolean = UInt8

@_extern(wasm, module: "webgl", name: "_setupContext")
func _setupContext(address: Int, byteCount: Int) -> Void

func setupGLContext(canvas: StaticString) {
    _setupContext(address: Int(bitPattern: canvas.utf8Start), byteCount: canvas.utf8CodeUnitCount)
}

@_extern(wasm, module: "webgl", name: "glViewport")
func glViewport(_ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32)

@_extern(wasm, module: "webgl", name: "glClearColor")
func glClearColor(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float)

@_extern(wasm, module: "webgl", name: "glClear")
func glClear(_ mask: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glEnable")
func glEnable(_ cap: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glDisable")
func glDisable(_ cap: Int32) -> Void

@_extern(wasm, module: "webgl", name: "glCreateProgram")
func glCreateProgram() -> UInt32

@_extern(wasm, module: "webgl", name: "glCreateShader")
func glCreateShader(_ type: Int32) -> UInt32

@_extern(wasm, module: "webgl", name: "glShaderSource")
func glShaderSource(_ shader: GLuint, _ count: GLsizei, _ string: UnsafePointer<UnsafePointer<GLchar>?>!, _ length: UnsafePointer<GLint>!) -> Void

@_extern(wasm, module: "webgl", name: "glCompileShader")
func glCompileShader(_ shader: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glAttachShader")
func glAttachShader(_ program: GLuint, _ shader: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glLinkProgram")
func glLinkProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glUseProgram")
func glUseProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glGetProgramiv")
func glGetProgramiv(_ program: GLuint, _ pname: GLenum, _ params: UnsafeMutablePointer<GLsizei>!) -> Void

@_extern(wasm, module: "webgl", name: "glGetProgramInfoLog")
func glGetProgramInfoLog(_ program: GLuint, _ bufSize: GLsizei, _ length: UnsafeMutablePointer<GLsizei>!, _ infoLog: UnsafeMutablePointer<GLchar>!) -> Void

@_extern(wasm, module: "webgl", name: "glValidateProgram")
func glValidateProgram(_ program: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glGetAttribLocation")
func glGetAttribLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> Int32

@_extern(wasm, module: "webgl", name: "glGetUniformLocation")
func glGetUniformLocation(_ program: GLuint, _ name: UnsafePointer<GLchar>!) -> Int32

@_extern(wasm, module: "webgl", name: "glVertexAttribPointer")
func glVertexAttribPointer(_ index: GLuint, _ size: GLint, _ type: GLenum, _ normalized: GLboolean, _ stride: GLsizei, _ pointer: UnsafeRawPointer!) -> Void

@_extern(wasm, module: "webgl", name: "glEnableVertexAttribArray")
func glEnableVertexAttribArray(_ index: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glDrawArrays")
func glDrawArrays(_ mode: GLint, _ first: GLint, _ count: GLsizei) -> Void

@_extern(wasm, module: "webgl", name: "glUniform1f")
func glUniform1f(_ location: GLint, _ v0: Float) -> Void

@_extern(wasm, module: "webgl", name: "glGenBuffers")
func glGenBuffers(_ n: GLsizei, _ buffers: UnsafeMutablePointer<GLuint>!) -> Void

@_extern(wasm, module: "webgl", name: "glBindBuffer")
func glBindBuffer(_ target: GLenum, _ buffer: GLuint) -> Void

@_extern(wasm, module: "webgl", name: "glBufferData")
func glBufferData(_ target: GLenum, _ size: GLsizei, _ data: UnsafeRawPointer!, _ usage: GLenum) -> Void
