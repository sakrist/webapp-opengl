import SwiftMath

class Sprite {

    public var model: mat4 = mat4.identity
    var modelArray: [Float] = []

    var image: Image?
    var frames: [Image] = []
    var currentFrame: Int = 0
    var frameTime: Double = 0
    var frameDuration: Double = 0.1 // Time per frame in seconds
    var animateFrames: Bool = true

    var position: vec2
    var size: vec2
    var rotate: Float
    var color:vec3 = vec3(1.0, 1.0, 1.0)
    
    private var animations: [Animation] = []
    var textureOffset: vec2 = vec2(0, 0)
    
    var name: String = ""

    init(position:vec2, size:vec2, rotate:Float, image: Image? = nil, frames: [Image] = []) {
    
        self.position = position
        self.size = size
        self.rotate = rotate
        self.frames = frames
    
        _recalc()
        
        // If we have frames, use first frame as main image
        if !frames.isEmpty {
            self.image = frames[0]
        } else {
            self.image = image
        }
    }

    func move(to position: vec2) {
        self.position = position
        _recalc()    
    }

    func animate(to newPosition: vec2, duration: Double) {
        animations.append(MoveAnimation(from: self.position, to: newPosition, duration: duration))
    }

    func animate(to newPosition: vec2, duration: Double, onComplete: (() -> Void)? = nil) {
        animations.append(MoveAnimation(from: self.position, 
                                     to: newPosition, 
                                     duration: duration, 
                                     onComplete: onComplete))
    }

    func animate(to newPosition: vec2, duration: Double, onComplete: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        let animation = MoveAnimation(from: self.position, to: newPosition, duration: duration, onComplete: onComplete)
        animation.onCancel = onCancel
        animations.append(animation)
    }
    
    func cancelAllAnimations() {
        animations.forEach { $0.cancel() }
    }
    
    func cancelLastAnimation() {
        animations.last?.cancel()
    }
    
    func reverseLastAnimation() {
        if let lastAnimation = animations.last {
            animations.append(lastAnimation.reverse())
        }
    }

    func update(delta: Double) {
        
        let animationsCopy = animations
        var completedAnimations: [Animation] = []
        for animation in animationsCopy {
            let isComplete = animation.update(delta)
            animation.apply(to: self)
            if isComplete {
                completedAnimations.append(animation)
            }
        }
        // Remove completed animations 
        animations.removeAll { animation in
            completedAnimations.contains { $0 === animation }
        }
        
        if !animations.isEmpty {
            _recalc()
        }
        
        // Update frame animation
        if frames.count > 1 && animateFrames {
            frameTime += delta
            if frameTime >= frameDuration {
                frameTime = 0
                currentFrame = (currentFrame + 1) % frames.count
                image = frames[currentFrame]
            }
        }
    }

    func _recalc() {
        
        var model = mat4.identity
        model = model.translated(by: vec3(position, 0.0))

        model = model.translated(by: vec3(0.5 * size.x, 0.5 * size.y, 0.0))
        model = model * mat4.rotate(z: .init(degrees: rotate))
        model = model.translated(by: vec3(-0.5 * size.x, -0.5 * size.y, 0.0))

        model = model * mat4.scale(sx: size.x, sy: size.y, sz: 1.0)
        self.model = model
        self.modelArray = model.toArray()
        
    }

    func isColliding(with sprite: Sprite) -> Bool {
        // Check if the sprite is colliding with another sprite
        return false
    }

    func isColliding(with sprite: Sprite, at x: Int, y: Int) -> Bool {
        // Check if the sprite is colliding with another sprite at a specific point
        return false
    }

    // func isColliding(with point: Point, at x: Int, y: Int) -> Bool {
    //     // Check if the sprite is coll
    // }
    

    func wrapAround(speed: vec2, bounds: (min: vec2, max: vec2)) {
        animations.append(WrapAroundAnimation(speed: speed, bounds: bounds, spriteSize: size))
    }
}