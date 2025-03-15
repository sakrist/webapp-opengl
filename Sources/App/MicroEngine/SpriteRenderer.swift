
import SwiftMath
import emswiften
#if canImport(emsdk)
import emsdk
#endif


class SpriteRenderer {

    var VBO: GLuint = 0
    var quadVAO: GLuint = 0
    let shader: Shader

    init(shader: Shader) {
        self.shader = shader
        let vertices: [Float] = [ 
            // pos      // tex
            0.0, 1.0, 0.0, 1.0,
            1.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 0.0, 

            0.0, 1.0, 0.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 0.0, 1.0, 0.0
        ]

        glGenVertexArrays(1, &quadVAO)
        glGenBuffers(1, &VBO)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        vertices.withUnsafeBytes { 
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizei(vertices.count * MemoryLayout<Float>.size), $0.baseAddress, GLenum(GL_STATIC_DRAW))
        }

        glBindVertexArray(quadVAO)
        glEnableVertexAttribArray(0)

        let posAttrib:GLuint = GLuint(shader.positionAttribute)

        glVertexAttribPointer(posAttrib, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(4 * MemoryLayout<Float>.size), nil)
        glEnableVertexAttribArray(posAttrib)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)

    }

    func draw(_ sprite: Sprite) {
        
        if let image = sprite.image {
            image.bind()
        }

        sprite.modelArray.withUnsafeBytes { ptr in
            ptr.baseAddress?.assumingMemoryBound(to: GLfloat.self).withMemoryRebound(to: GLfloat.self, capacity: 16) { floatPtr in
                glUniformMatrix4fv(GLint(shader.modelUniform), 1, GLboolean(GL_FALSE), floatPtr)
            }
        }
        
        glBindVertexArray(quadVAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
    }

    deinit {
        glDeleteVertexArrays(1, &quadVAO)
        glDeleteBuffers(1, &VBO)
    }
}