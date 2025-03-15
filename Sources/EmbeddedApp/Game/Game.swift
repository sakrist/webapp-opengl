import SwiftMath

enum GameState {
    case start
    case playing
    case gameOver
}

class Game {

    var state: GameState = .start

    var ground1: Sprite?
    var ground2: Sprite?
    var bird: Bird?
    var sprites: [Sprite] = []

    let renderer: SpriteRenderer
    var viewSize: vec2
    init(renderer: SpriteRenderer, viewSize: vec2) {
        self.renderer = renderer
        self.viewSize = viewSize
    }

    func createWorld() {

        let bg = Image.init(name: "BG.png")
        let bgSprite = Sprite(
            position: vec2(0, 0),
            size: vec2(viewSize.width, 230), rotation: 0.0, frames: [bg])
        sprites.append(bgSprite)

        let birdImages = [
            Image.init(name: "bird/b0.png"),
            Image.init(name: "bird/b1.png"),
            Image.init(name: "bird/b2.png"),
        ]
        let birdSprite = Bird(
            position: vec2(100, 200), size: vec2(34, 26), rotation: 0.0, frames: birdImages)
        birdSprite.animateFrames = false
        sprites.append(birdSprite)
        bird = birdSprite

        let groundSize:Float = viewSize.width
        let ground = Image.init(name: "ground.png")
        
        // First ground sprite
        let groundSprite1 = Sprite(
            position: vec2(0, 0), 
            size: vec2(groundSize, 112), 
            rotation: 0.0, 
            frames: [ground])
        
        // Position second sprite exactly at the end of first sprite
        let groundSprite2 = Sprite(
            position: vec2(groundSize, 0),
            size: vec2(groundSize, 112), 
            rotation: 0.0, 
            frames: [ground])
        
        sprites.append(groundSprite1)
        sprites.append(groundSprite2)
        ground1 = groundSprite1
        ground2 = groundSprite2

        bird?.colliders = [groundSprite1, groundSprite2]

    }

    func animateGround() {
        let groundSize:Float = viewSize.width
        // Set bounds to exactly one groundSize width
        let bounds = (
            min: vec2(2, 0),
            max: vec2(groundSize, 0)
        )
        let scrollSpeed = vec2(-2, 0)
        
        ground1?.wrapAround(speed: scrollSpeed, bounds: bounds)
        ground2?.wrapAround(speed: scrollSpeed, bounds: bounds)
    }

    func stopGround() {
        ground1?.cancelAllAnimations()
        ground2?.cancelAllAnimations()
    }

    func event() {
        switch state {
        case .start:
            play()
        case .playing:
            bird?.flap()
        case .gameOver:
            state = .start
        }
    }

    func play() {
        state = .playing
        bird?.state = .playing
        bird?.animateFrames = true
        bird?.collisioned = {
            self.stop()
        }
        animateGround()
    }

    func stop() {
        state = .gameOver
        bird?.state = .gameOver
        bird?.animateFrames = false
        stopGround()
    }

    func update(delta: Double) {


        for sprite in sprites {
            sprite.update(delta: delta)
            renderer.draw(sprite)
        }
    }

}