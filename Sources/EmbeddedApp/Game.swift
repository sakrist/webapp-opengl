import SwiftMath

class Game {


    var ground1: Sprite?
    var ground2: Sprite?
    var bird: Bird?
    var sprites: [Sprite] = []

    var viewSize: vec2
    init(viewSize: vec2) {
        self.viewSize = viewSize
    }

    func createWorld() {

        let bg = Image.init(name: "BG.png")
        let bgSprite = Sprite(
            position: vec2(0, 0),
            size: vec2(viewSize.width, 230), rotate: 0.0, frames: [bg])
        sprites.append(bgSprite)

        let birdImages = [
            Image.init(name: "bird/b0.png"),
            Image.init(name: "bird/b1.png"),
            Image.init(name: "bird/b2.png"),
        ]
        let birdSprite = Bird(
            position: vec2(100, 200), size: vec2(34, 26), rotate: 0.0, frames: birdImages)
        birdSprite.animateFrames = false
        sprites.append(birdSprite)
        bird = birdSprite

        let groundSize:Float = viewSize.width
        let ground = Image.init(name: "ground.png")
        
        // First ground sprite
        let groundSprite1 = Sprite(
            position: vec2(0, 0), 
            size: vec2(groundSize, 112), 
            rotate: 0.0, 
            frames: [ground])
        
        // Position second sprite exactly at the end of first sprite
        let groundSprite2 = Sprite(
            position: vec2(groundSize, 0),
            size: vec2(groundSize, 112), 
            rotate: 0.0, 
            frames: [ground])
        
        sprites.append(groundSprite1)
        sprites.append(groundSprite2)
        ground1 = groundSprite1
        ground2 = groundSprite2

        animateGround()
    }

    func animateGround() {
        let groundSize:Float = viewSize.width
        // Set bounds to exactly one groundSize width
        let bounds = (
            min: vec2(0, 0),
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



    func play() {
        bird?.animateFrames = true

    }

}