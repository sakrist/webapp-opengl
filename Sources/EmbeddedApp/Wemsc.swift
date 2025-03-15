
#if canImport(emsdk)
import emsdk
#endif

// single most important function to support from emscripten libc.

@_extern(wasm, module: "env", name: "emscripten_date_now")
func _emscripten_date_now() -> Double

@_cdecl("emscripten_date_now")
func emscripten_date_now() -> Double {
    return _emscripten_date_now()
}
