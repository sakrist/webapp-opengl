#if canImport(emsdk)
import emsdk
#endif
#if canImport(COpenGL)
import COpenGL
#endif

class ShaderBase {
    let program: UInt32
    let vertexShader: UInt32
    let fragmentShader: UInt32
    let valid: Bool

    init(vertexSource: StaticString, fragmentSource: StaticString) {
        program = glCreateProgram()
        vertexShader = ShaderBase.createShader(shaderSource: vertexSource, shaderType: GL_VERTEX_SHADER)
        fragmentShader = ShaderBase.createShader(shaderSource: fragmentSource, shaderType: GL_FRAGMENT_SHADER)

        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        glLinkProgram(program)
        glUseProgram(program)

        valid = ShaderBase.validateProgram(prog: program)
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
