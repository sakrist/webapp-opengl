import SwiftMath
#if canImport(emsdk)
import emsdk
#endif

class Animation {
    var onComplete: (() -> Void)?
    var onCancel: (() -> Void)?
    var isCancelled = false
    
    func cancel() {
        isCancelled = true
        onCancel?()
    }
    
    func update(_ deltaTime: Double) -> Bool { return true }
    func apply(to sprite: Sprite) { }
    func reverse() -> Animation { return self }
}

class MoveAnimation: Animation {
    private var startPosition: vec2
    private var endPosition: vec2
    private var duration: Double
    private var elapsedTime: Double = 0
    
    init(from: vec2, to: vec2, duration: Double, onComplete: (() -> Void)? = nil) {
        self.startPosition = from
        self.endPosition = to
        self.duration = duration
        super.init()
        self.onComplete = onComplete
    }
    
    override func update(_ deltaTime: Double) -> Bool {
        if isCancelled { return true }
        elapsedTime += deltaTime
        let completed = elapsedTime >= duration
        if completed {
            onComplete?()
        }
        return completed
    }
    
    override func apply(to sprite: Sprite) {
        let t = min(elapsedTime / duration, 1.0)
        sprite.position = vec2(
            x: startPosition.x + (endPosition.x - startPosition.x) * Float(t),
            y: startPosition.y + (endPosition.y - startPosition.y) * Float(t)
        )
    }
    
    override func reverse() -> MoveAnimation {
        return MoveAnimation(from: endPosition, to: startPosition, duration: duration, onComplete: onComplete)
    }
}

class WrapAroundAnimation: Animation {
    private let speed: vec2
    private let bounds: (min: vec2, max: vec2)
    private let spriteSize: vec2
    
    init(speed: vec2, bounds: (min: vec2, max: vec2), spriteSize: vec2) {
        self.speed = speed
        self.bounds = bounds
        self.spriteSize = spriteSize
        super.init()
    }
    
    override func update(_ deltaTime: Double) -> Bool {
        if isCancelled { return true }
        return false // Continuous animation never completes
    }
    
    override func apply(to sprite: Sprite) {
        var newPosition = sprite.position
        newPosition.x += speed.x
        newPosition.y += speed.y
        
        // Wrap around logic
        if newPosition.x + spriteSize.x < bounds.min.x {
            newPosition.x = bounds.max.x
        } else if newPosition.x > bounds.max.x {
            newPosition.x = bounds.min.x - spriteSize.x
        }
        
        if newPosition.y + spriteSize.y < bounds.min.y {
            newPosition.y = bounds.max.y
        } else if newPosition.y > bounds.max.y {
            newPosition.y = bounds.min.y - spriteSize.y
        }
        
        sprite.position = newPosition
    }
}


