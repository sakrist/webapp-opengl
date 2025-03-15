import JavaScriptKit

class RunLoop {

    static let main = RunLoop()
    
    private var storedCallback: (() -> Void)?

    func _requestNextFrame() {
        _ = JSObject.global.requestAnimationFrame!( JSClosure { _ in
            if let storedCallback = self.storedCallback {
                storedCallback()
                self._requestNextFrame()
            }
            return .undefined
        })
    }

    func setMainLoop(_ callback: @escaping () -> Void) {
        storedCallback = callback
        _requestNextFrame()
    }

    func cancelMainLoop() {
        storedCallback = nil
    }
}