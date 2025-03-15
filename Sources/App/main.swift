import JavaScriptKit
#if canImport(emsdk)
import emsdk
#endif
#if canImport(WASILibc)
import WASILibc
#endif

import SwiftMath
#if canImport(emswiften)
import emswiften
#endif


let app = App(viewSize: vec2(400, 500))

func main() {

    app.setup()

    print("time = \(time(nil))")

/// ----------------- Math test -----------------
    let n:Double = 10
    let number = sqrt(n);
    print("sqrt(\(n)) = \(number)")

    // experiment with math library
    let a = vec3(1, 2, 3)
    let len = a.length
    let nrom = a.normalized
    print("vec a = \(a), length = \(len), normalized = \(nrom)")
}


main()