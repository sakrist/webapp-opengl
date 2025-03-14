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

    if let gl = canvas.getContext?("webgl2") {
    //     print("WebGL is supported")
        canvas.width = 600
        canvas.height = 400
        // _ = gl.viewport(0, 0, 800, 600);
        // _ = gl.clearColor(1.0, 0.0, 0.0, 1.0);
        // _ = gl.clear(gl.COLOR_BUFFER_BIT);
        
    } else {
        print("WebGL is not supported")
    }

    setupGLContext(canvas: "canvas")
    
    let shader = Shader()

    glViewport(0, 0, 600, 400)
    glClearColor(1.0, 0.0, 0.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT)

    // Set up vertex data
    let vertices: [Float] = [
        0.0,  0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    ]

    var vbo: GLuint = 0
    glGenBuffers(1, &vbo)
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
    glBufferData(GLenum(GL_ARRAY_BUFFER), 
                 GLsizei(MemoryLayout<Float>.stride * vertices.count), 
                 vertices, 
                 GLenum(GL_STATIC_DRAW))

    // Set up vertex attributes
    let posAttrib = glGetAttribLocation(shader.program, "position")
    glVertexAttribPointer(GLuint(posAttrib), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
    glEnableVertexAttribArray(GLuint(posAttrib))
   
    glClear(GL_COLOR_BUFFER_BIT);
    shader.use()
    glDrawArrays(GL_TRIANGLES, 0, 3);



/// ----------------- Math test -----------------
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