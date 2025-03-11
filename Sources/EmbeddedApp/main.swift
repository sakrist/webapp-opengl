import JavaScriptKit
#if canImport(emsdk)
import emsdk
#endif
#if canImport(WASILibc)
import WASILibc
#endif

import SwiftMath
import emswiften 


func main() {

    guard
    case .object(let canvas) = JSObject.global.document.createElement("canvas")
    else
    {
        print("Could not create elements")
        fatalError("Could not create elements")
    }
    _ = JSObject.global.document.body.appendChild(canvas)
    canvas.id = "canvas"

    // if let gl = canvas.getContext?("webgl") {
    //     print("WebGL is supported")
    //     canvas.width = 800
    //     canvas.height = 600
    //     _ = gl.viewport(0, 0, 800, 600);
    //     _ = gl.clearColor(1.0, 0.0, 0.0, 1.0);
    //     _ = gl.clear(gl.COLOR_BUFFER_BIT);
    // } else {
    //     print("WebGL is not supported")
    // }

    setupGLContext(canvas: "canvas")
    glViewport(0, 0, 800, 600)
    glClearColor(1.0, 0.0, 0.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)


    let n:Double = 10
    let number = sqrt(n);
    print("sqrt(\(n)) = \(number)")

    // experiment with math library
    let a = vec3(1, 2, 3)
    let len = a.length
    let nrom = a.normalized
    print("vec a = \(a), length = \(len), normalized = \(nrom)")
}
main()