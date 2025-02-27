import JavaScriptKit

func print(_ message: String) {
    _ = JSObject.global.console.log(message)
}

extension String {
    // native string comparison would require unicode stuff
    @inline(__always)
    func utf8Equals(_ other: borrowing String) -> Bool {
        utf8.elementsEqual(other.utf8)
    }
}

