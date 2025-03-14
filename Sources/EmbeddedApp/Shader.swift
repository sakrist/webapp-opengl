
#if canImport(emsdk)
import emsdk
#endif
#if canImport(WASILibc)
import WASILibc
#endif
import emswiften

public class Shader {

    let program: UInt32
    let vertexShader: UInt32
    let fragmentShader: UInt32

    let positionAttribute: Int32

    init(vertexSource:StaticString, fragmentSource: StaticString) {

        program = glCreateProgram()
        vertexShader = Shader.createShader(shaderSource: vertexSource, shaderType: GL_VERTEX_SHADER)
        fragmentShader = Shader.createShader(shaderSource: fragmentSource, shaderType: GL_FRAGMENT_SHADER)

        print("program = \(program), vertexShader = \(vertexShader), fragmentShader = \(fragmentShader)")

        // Attach vertex shader to program.
        glAttachShader(program, vertexShader)
        
        // Attach fragment shader to program.
        glAttachShader(program, fragmentShader)
        
        glLinkProgram(program)
        
        // Set up vertex attributes
        positionAttribute = glGetAttribLocation(program, "position")

        if (Shader.validateProgram(prog: program)) {
            print("Program is valid")
        } else {
            print("Program is invalid")
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