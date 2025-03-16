import JavaScriptKit

#if hasFeature(Embedded)
// NOTE: it seems the embedded tree shaker gets rid of these exports if they are not used somewhere
func _i_need_to_be_here_for_wasm_exports_to_work() {
    _ = _swjs_library_features
    _ = _swjs_call_host_function
    _ = _swjs_free_host_function
}
#endif

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


extension JSObject {
    subscript(dynamicMember name: String) -> JSValue {
        get { self[name] }
        set { self[name] = newValue }
    }
    
    // Add support for Float assignments
    subscript(dynamicMember name: String) -> Float {
        get { Float(self[name].number ?? 0) }
        set { self[name] = JSValue.number(Double(newValue)) }
    }
    
    // Add support for Int assignments
    subscript(dynamicMember name: String) -> Int {
        get { Int(self[name].number ?? 0) }
        set { self[name] = JSValue.number(Double(newValue)) }
    }
}
