
#if canImport(emsdk)
import emsdk
#endif
#if canImport(WASILibc)
import WASILibc
#endif



public class Shader {

    static let vertexShaderSource:StaticString =
"""
#version 300 es
attribute vec4 position;
out vec2 TexCoords;

uniform mat4 model;
uniform mat4 projection;

void main() {
    // gl_Position = position;
    TexCoords = position.zw;
    gl_Position = projection * model * vec4(position.xy, 0.0, 1.0);
}
"""

static let fragmentShaderSource:StaticString =
"""
#version 300 es
precision mediump float;
in vec2 TexCoords;
out vec4 outColor;

uniform sampler2D image;
uniform vec3 spriteColor;

uniform float time;

void main() {
    // vec2 uv = gl_FragCoord.xy/vec2(600.0, 400.0);
    // float t = time * 0.001;
    // float color = sin(uv.x * 10.0 + t) * cos(uv.y * 10.0 + t);
    // outColor = vec4(abs(sin(t)), color, abs(cos(t)), 1.0);

    outColor = texture(image, TexCoords);
}
"""

    let program: UInt32
    let vertexShader: UInt32
    let fragmentShader: UInt32

    let positionAttribute: Int32

    // uniform locations
    let modelUniform: Int32
    let projectionUniform: Int32
    // fragment shader uniforms
    let spriteColorUniform: Int32
    let imageUniform: Int32
    let timeUniform: Int32

    let valid: Bool


    init(vertexSource:StaticString = vertexShaderSource, fragmentSource: StaticString = fragmentShaderSource) {

        program = glCreateProgram()
        vertexShader = Shader.createShader(shaderSource: vertexSource, shaderType: GL_VERTEX_SHADER)
        fragmentShader = Shader.createShader(shaderSource: fragmentSource, shaderType: GL_FRAGMENT_SHADER)

        print("program = \(program), vertexShader = \(vertexShader), fragmentShader = \(fragmentShader)")

        // Attach vertex shader to program.
        glAttachShader(program, vertexShader)
        
        // Attach fragment shader to program.
        glAttachShader(program, fragmentShader)
        
        glLinkProgram(program)

        glUseProgram(program)
        
        modelUniform = glGetUniformLocation(program, "model")
        projectionUniform = glGetUniformLocation(program, "projection")
        spriteColorUniform = glGetUniformLocation(program, "spriteColor")
        imageUniform = glGetUniformLocation(program, "image")
        timeUniform = glGetUniformLocation(program, "time")

        
        if (imageUniform != -1) {
            glUniform1i(imageUniform, 0)
        } else {
            print("imageUniform not found")
        }
        
        if (spriteColorUniform != -1) {
            glUniform3f(spriteColorUniform, 1, 1, 1)
        } 

        // Set up vertex attributes
        positionAttribute = glGetAttribLocation(program, "position")

        if (Shader.validateProgram(prog: program)) {
            print("Program is valid")
            valid = true
        } else {
            print("Program is invalid")
            valid = false
        }
    }

    func use() {
        glUseProgram(program)
    }

    static func createShader(shaderSource:StaticString, shaderType:Int32) -> UInt32 {
        let shader: UInt32 = glCreateShader(shaderType)

        let source = UnsafeMutablePointer<Int8>.allocate(capacity: shaderSource.utf8CodeUnitCount)
        let size = shaderSource.utf8CodeUnitCount
        for idx in 0..<size {
            let u = shaderSource.utf8Start[idx]
            source[idx] = Int8(u)
        }
        source[size] = 0
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        source.deallocate()

        var logLength: GLint = 0
        glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 1 {
            var log = [GLchar](repeating: 0, count: 512)
            glGetShaderInfoLog(shader, 512, &logLength, &log)
            
            let logString = String(cString:log)
            print(logString)
            
        }
        
        return shader
    }

    static func validateProgram(prog: GLuint) -> Bool {
        var logLength: GLint = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](repeating: 0, count: Int(logLength))
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            print("Program validate log: \(String(cString:log))")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }
}