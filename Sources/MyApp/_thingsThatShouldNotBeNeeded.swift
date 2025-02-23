
// TODO: move this to C
@_cdecl("strlen")
func strlen(_ s: UnsafePointer<Int8>) -> Int {
    var p = s
    while p.pointee != 0 {
        p += 1
    }
    return p - s
}

enum LCG {
    static var x: UInt8 = 0
    static let a: UInt8 = 0x05
    static let c: UInt8 = 0x0B

    static func next() -> UInt8 {
        x = a &* x &+ c
        return x
    }
}

// TODO: move this to C
@_cdecl("arc4random_buf")
public func arc4random_buf(_ buffer: UnsafeMutableRawPointer, _ size: Int) {
    for i in 0 ..< size {
        buffer.storeBytes(of: LCG.next(), toByteOffset: i, as: UInt8.self)
    }
}

