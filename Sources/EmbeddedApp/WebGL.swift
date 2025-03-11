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
