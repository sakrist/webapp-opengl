import SwiftMath
#if canImport(emswiften)
import emswiften
#endif
#if canImport(emsdk)
import emsdk
#endif
#if canImport(COpenGL)
import COpenGL
#endif


class SpriteRenderer {

    var VBO: GLuint = 0
    var quadVAO: GLuint = 0
    let spriteShader: ShaderSprites
    let particleShader: ShaderParticles
    var pointVBO: GLuint = 0
    var pointVAO: GLuint = 0

    init(spriteShader: ShaderSprites, particleShader: ShaderParticles) {
        self.spriteShader = spriteShader
        self.particleShader = particleShader
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

        let posAttrib:GLuint = GLuint(spriteShader.positionAttribute)

        glVertexAttribPointer(posAttrib, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(4 * MemoryLayout<Float>.size), nil)
        glEnableVertexAttribArray(posAttrib)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindVertexArray(0)

        // Initialize point rendering
        glGenVertexArrays(1, &pointVAO)
        glGenBuffers(1, &pointVBO)
        
        glBindVertexArray(pointVAO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointVBO)
        glEnableVertexAttribArray(0)
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
    }

    func draw(_ sprite: Sprite) {
        spriteShader.use()
        
        if let image = sprite.image {
            image.bind()
        }

        sprite.modelArray.withUnsafeBytes { ptr in
            ptr.baseAddress?.assumingMemoryBound(to: GLfloat.self).withMemoryRebound(to: GLfloat.self, capacity: 16) { floatPtr in
                glUniformMatrix4fv(GLint(spriteShader.modelUniform), 1, GLboolean(GL_FALSE), floatPtr)
            }
        }
        
        glBindVertexArray(quadVAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
    }

    func drawPoint(at position: vec2, size: Float, color: vec3, alpha: Float) {
        particleShader.use()
        
        let vertices: [Float] = [position.x, position.y]
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointVBO)
        vertices.withUnsafeBytes {
            glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizei(MemoryLayout<Float>.size * 2), 
                        $0.baseAddress, GLenum(GL_STREAM_DRAW))
        }
        
        glUniform1f(glGetUniformLocation(particleShader.program, "pointSize"), size)
        glUniform3f(glGetUniformLocation(particleShader.program, "color"), 
                   color.x, color.y, color.z)
        glUniform1f(glGetUniformLocation(particleShader.program, "alpha"), alpha)
                
        glBindVertexArray(pointVAO)
        glDrawArrays(GL_POINTS, 0, 1)
        glBindVertexArray(0)
        
    }

    deinit {
        glDeleteVertexArrays(1, &quadVAO)
        glDeleteBuffers(1, &VBO)
        glDeleteVertexArrays(1, &pointVAO)
        glDeleteBuffers(1, &pointVBO)
    }
}