import SwiftMath

class ShaderParticles: ShaderBase {
    static let vertexShaderSource:StaticString = """
    #version 300 es
    attribute vec2 position;
    uniform mat4 projection;
    uniform float pointSize;
    void main() {
        gl_Position = projection * vec4(position, 0.0, 1.0);
        gl_PointSize = pointSize;
    }
    """

    static let fragmentShaderSource:StaticString = """
    #version 300 es
    precision mediump float;
    uniform vec3 color;
    uniform float alpha;
    out vec4 outColor;
    void main() {
        vec2 coord = gl_PointCoord - vec2(0.5);
        float r = length(coord) * 2.0;
        float a = 1.0 - smoothstep(0.8, 1.0, r);
        outColor = vec4(color, alpha * a);
    }
    """

    var positionAttribute: Int32 = 0
    var projectionUniform: Int32 = 0
    var pointSizeUniform: Int32 = 0
    var colorUniform: Int32 = 0
    var alphaUniform: Int32 = 0

    init() {
        super.init(vertexSource: Self.vertexShaderSource, 
                  fragmentSource: Self.fragmentShaderSource)

        positionAttribute = glGetAttribLocation(program, "position")
        projectionUniform = glGetUniformLocation(program, "projection")
        pointSizeUniform = glGetUniformLocation(program, "pointSize")
        colorUniform = glGetUniformLocation(program, "color")
        alphaUniform = glGetUniformLocation(program, "alpha")
    }
}
