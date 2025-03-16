import JavaScriptKit
import SwiftMath

#if canImport(emsdk)
import emsdk
#endif

#if canImport(COpenGL)
import COpenGL
#endif


func time() -> Double {
#if canImport(emsdk)
    var tp: timeval = timeval()
    gettimeofday(&tp, nil)
    return Double(tp.tv_sec * 1000 + Int64(tp.tv_usec / 1000)) / 1000.0;
#elseif canImport(WASILibc)
    return (JSObject.global.performance.now().number ?? 0) / 1000.0
#endif
}


class App {

    var viewSize: vec2
    var lastTime: Double = 0

    var projection: mat4 = mat4.identity
    var projectionArray: [Float] = []

    let shader: Shader
    let spriteRenderer: SpriteRenderer
    let game: Game

    init(viewSize: vec2 = vec2(600, 400)) {
        self.viewSize = viewSize

        projection = mat4.ortho(left: 0, right: viewSize.x, bottom: 0, top: viewSize.y, near: -1, far: 1)
        projectionArray = projection.toArray()

        guard
            case .object(let canvas) = JSObject.global.document.createElement("canvas")
        else {
            print("Could not create elements")
            fatalError("Could not create elements")
        }
        _ = JSObject.global.document.body.appendChild(canvas)
        canvas.id = "canvas"
        canvas.style = "border:1px solid #000000;"

        if let _ = canvas.getContext?("webgl2") {
            print("WebGL2 is supported")
            canvas.width = viewSize.x
            canvas.height = viewSize.y
        } else {
            print("WebGL is not supported")
        }

        // setup GL context
        setupGLContext(canvas: "canvas")

        glEnable(Int32(GL_BLEND))
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

        shader = Shader()
        spriteRenderer = SpriteRenderer(shader: shader)

        game = Game(renderer: spriteRenderer, viewSize: viewSize)
        game.createWorld()

        canvas.onclick = JSValue.object( JSClosure { _ in
            self.game.event()
            return .undefined
        })        
    }


    func setup() {
        glDisable(GL_CULL_FACE)
        if (!shader.valid) {
            print("Shader program is not initialized")
            return
        }
        RunLoop.main.setMainLoop(render)
    }

    func render() {

        glViewport(0, 0, Int32(viewSize.x), Int32(viewSize.y))
        glClearColor(0.18, 0.746, 0.867, 1.0)
        glClear(GL_COLOR_BUFFER_BIT)

        let time1: Double = time()
        let deltaTime = time1 - lastTime
        
        shader.use()
        projectionArray.withUnsafeBytes { ptr in
            ptr.baseAddress?.assumingMemoryBound(to: GLfloat.self).withMemoryRebound(
                to: GLfloat.self, capacity: 16
            ) { floatPtr in
                glUniformMatrix4fv(
                    GLint(shader.projectionUniform), 1, GLboolean(GL_FALSE), floatPtr)
            }
        }
        if (shader.timeUniform != -1) {
            glUniform1f(shader.timeUniform, Float(lastTime))
        }

        game.update(delta: deltaTime)

        lastTime = time1
    }
}