import JavaScriptKit
import emsdk

func main() {

    guard
    case .object(let canvas) = JSObject.global.document.createElement("canvas")
    else
    {
        print("Could not create elements")
        fatalError("Could not create elements")
    }
    _ = JSObject.global.document.body.appendChild(canvas)

    if var gl = canvas.getContext?("webgl") {
        print("WebGL is supported")
        canvas.width = 800
        canvas.height = 600
        gl.viewport(0, 0, 800, 600);
        gl.clearColor(1.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

    } else {
        print("WebGL is not supported")
    }


    let number = sqrt(4);
    print("sqrt(4) = \(number)")

}
main()