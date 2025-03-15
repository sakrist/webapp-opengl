
import JavaScriptKit


class ResourceLoader {
    
    static func generateText(string: String, size:Int, width: Int, height: Int, completion: @escaping (Int, Int, [UInt8]) -> Void) {
        let text = string
        var canvas = JSObject.global.document.createElement("canvas")
        var ctx = canvas.getContext("2d")

        let width = width
        let height = height

        canvas.width = .init(integerLiteral: Int32(width))
        canvas.height = .init(integerLiteral: Int32(height))
        _ = ctx.clearRect(0, 0, width, height)
        
        ctx.font = .init(stringLiteral: "\(size)px Lato")
        ctx.fillStyle = "white"
        ctx.strokeStyle = "white"
        _ = ctx.scale(1, -1)
        _ = ctx.translate(0, -height)
        _ = ctx.fillText(text, 0 , height);
        _ = ctx.strokeText(text, 0 , height);
        
        let imageData = ctx.getImageData(0, 0, width, height)
        let data1 = imageData.data
        let dataLength = Int(data1.length.number ?? 0)
        var dataBytes = [UInt8](repeating: 0, count: dataLength)
        for i in 0..<dataLength {
            dataBytes[i] = UInt8(data1[i].number ?? 0)
        }
        completion(width, height, dataBytes)
    }

    static func loadImageData(name: String, completion: @escaping (Int, Int, [UInt8]) -> Void) {
        
        // TODO: replace with loading from filesystem and use libpng or similar
        
        var image = JSObject.global.document.createElement("img")
        image.onload = JSValue.object(
            JSClosure { _ in

                let width = Int(image.width.number ?? 0)
                let height = Int(image.height.number ?? 0)
                // convert image to data
                var canvas = JSObject.global.document.createElement("canvas")
                let ctx = canvas.getContext("2d")
                canvas.width = .init(integerLiteral: Int32(width))
                canvas.height = .init(integerLiteral: Int32(height))
                // _ = ctx.fillStyle = "rgba(0, 0, 0, 0)"
                _ = ctx.clearRect(0, 0, width, height)
                _ = ctx.scale(1, -1)
                _ = ctx.translate(0, -height)
                _ = ctx.drawImage(image, 0, 0)
                let imageData = ctx.getImageData(0, 0, width, height)
                let data1 = imageData.data
                let dataLength = Int(data1.length.number ?? 0)
                var dataBytes = [UInt8](repeating: 0, count: dataLength)
                for i in 0..<dataLength {
                    dataBytes[i] = UInt8(data1[i].number ?? 0)
                }
                completion(width, height, dataBytes)
                
                return .undefined
            })
        image.src = .init(stringLiteral: "./img/\(name)")
    }
}