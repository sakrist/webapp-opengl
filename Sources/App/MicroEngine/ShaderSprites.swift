import SwiftMath

class ShaderSprites: ShaderBase {
    static let vertexShaderSource:StaticString = """
    #version 300 es
    attribute vec4 position;
    out vec2 TexCoords;
    uniform mat4 model;
    uniform mat4 projection;
    void main() {
        TexCoords = position.zw;
        gl_Position = projection * model * vec4(position.xy, 0.0, 1.0);
    }
    """

    static let fragmentShaderSource:StaticString = """
    #version 300 es
    precision mediump float;
    in vec2 TexCoords;
    out vec4 outColor;
    uniform sampler2D image;
    void main() {
        outColor = texture(image, TexCoords);
    }
    """

    var positionAttribute: Int32 = 0
    var modelUniform: Int32 = 0
    var projectionUniform: Int32 = 0
    var imageUniform: Int32 = 0

    init() {
        super.init(vertexSource: Self.vertexShaderSource, 
                  fragmentSource: Self.fragmentShaderSource)
        
        self.positionAttribute = glGetAttribLocation(program, "position")
        self.modelUniform = glGetUniformLocation(program, "model")
        self.projectionUniform = glGetUniformLocation(program, "projection")
        self.imageUniform = glGetUniformLocation(program, "image")

        if (imageUniform != -1) {
            glUniform1i(imageUniform, 0)
        }
    }
}
