import JavaScriptKit

#if canImport(emsdk)
    import emsdk
#endif

class Image {
    var width: Int
    var height: Int
    var data: [UInt8]
    let name: String
    var texture: GLuint = 0

    init(text: String, size: Int, width: Int, height: Int) {
        self.width = width
        self.height = height
        self.data = [0, 0, 0, 255]
        self.name = text

        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)

        // Set texture parameters
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

        glTexImage2D(
            GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(self.width), GLsizei(self.height), 0,
            GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), self.data)

        ResourceLoader.generateText(string: text, size: size, width: width, height: height) { w, h, imageData in
            self.width = w
            self.height = h
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
            glTexImage2D(
                GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(self.width), GLsizei(self.height), 0,
                GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        }

    }

    init(name: String) {
        self.width = 1
        self.height = 1
        self.data = [0, 0, 0, 255]
        self.name = name

        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)

        // Set texture parameters
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)

        glTexImage2D(
            GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(self.width), GLsizei(self.height), 0,
            GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), self.data)

        ResourceLoader.loadImageData(name: name) { w, h, imageData in
            self.width = w
            self.height = h
            glBindTexture(GLenum(GL_TEXTURE_2D), self.texture)
            glTexImage2D(
                GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(self.width), GLsizei(self.height), 0,
                GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        }

    }

    func bind() {
        glActiveTexture(GLenum(GL_TEXTURE0));
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
    }
}
