import SwiftMath
#if canImport(emsdk)
import emsdk
#endif

enum GameState {
    case start
    case playing
    case gameOver
}

class Game {

    var best: Int = 0
    var score: Int = 0

    var state: GameState = .start

    var ground1: Sprite?
    var ground2: Sprite?
    var bird: Bird?
    var pipes: Pipes?
    var sprites: [Sprite] = []

    var gameOver: Sprite?
    var scoreSprite: Sprite?
    var bestSprite: Sprite?
    var tapStartSprite: Sprite?

    let renderer: SpriteRenderer
    var viewSize: vec2
    private let particles = ParticleSystem(maxParticles: 100)
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

        let pipes = Pipes(viewSize: viewSize)
        sprites.append(pipes)
        pipes.incrementScore = {
            self.score += 1
        }
        self.pipes = pipes

        let birdImages = [
            Image.init(name: "bird/b0.png"),
            Image.init(name: "bird/b1.png"),
            Image.init(name: "bird/b2.png"),
        ]
        let birdSprite = Bird(
            position: vec2(100, viewSize.y/2), size: vec2(34, 26), rotation: 0.0, frames: birdImages)
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

        let image = Image.init(name: "go.png")
        gameOver = Sprite(
            position: vec2(viewSize.x/2 - 100, viewSize.y/2),
            size: vec2(200, 100), rotation: 0.0, frames: [image])
        gameOver?.hidden = true
        sprites.append(gameOver!)
        

        let tapStartSprite = Sprite(
            position: vec2(viewSize.x/2 - 50, viewSize.y/2 + 50),
            size: vec2(118, 36),
            rotation: 0.0,
            frames: [Image(name: "tap/t0.png"), Image(name: "tap/t1.png")]
        )
        tapStartSprite.frameDuration = 0.2
        sprites.append(tapStartSprite)
        self.tapStartSprite = tapStartSprite

    }

    func removeScore() {
        if let oldScore = scoreSprite {
            sprites.removeAll(where: { $0 === oldScore })
        }
        if let oldBest = bestSprite {
            sprites.removeAll(where: { $0 === oldBest })
        }
    }
    
    func updateScoreDisplay() {
        removeScore()
        
        let scoreText =  "Score: \(score)"
        let scoreImage = Image(text: scoreText, size: 28, width: 120, height: 32)
        scoreSprite = Sprite(
            position: vec2(viewSize.x/2 - 60, viewSize.y - 100),
            size: vec2(120, 32),
            rotation: 0.0,
            frames: [scoreImage]
        )

        // best
        let bestText =  "Best: \(best)"
        let bestImage = Image(text: bestText, size: 28, width: 120, height: 32)
        bestSprite = Sprite(
            position: vec2(viewSize.x/2 - 60, viewSize.y - 130),
            size: vec2(120, 32),
            rotation: 0.0,
            frames: [bestImage]
        )
        
        if let scoreSprite = scoreSprite {
            sprites.append(scoreSprite)
        }
        if let bestSprite = bestSprite {
            sprites.append(bestSprite)
        }
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
            if let birdPosition = bird?.position {
                particles.emit(at: birdPosition)
            }
        case .gameOver:
            state = .start
            reset()
        }
    }

    func play() {
        state = .playing
        bird?.state = .playing
        pipes?.state = .playing
        bird?.animateFrames = true
        bird?.collisioned = {
            self.stop()
        }
        animateGround()
        tapStartSprite?.hidden = true
    }

    func stop() {
        state = .gameOver
        bird?.state = .gameOver
        pipes?.state = .gameOver
        bird?.animateFrames = false
        stopGround()
        gameOver?.hidden = false
        best = max(score, best)

        updateScoreDisplay()
    }

    func reset() {
        bird?.position = vec2(100, viewSize.y/2)
        bird?.velocity = vec2(0, 0)
        bird?.rotation = 0
        bird?.state = .start
        bird?._recalc()
        bird?.animateFrames = false
        bird?.cancelAllAnimations()
        gameOver?.hidden = true
        pipes?.state = .start
        pipes?.reset()
        score = 0
        tapStartSprite?.hidden = false
        removeScore()
    }

    func update(delta: Double) {
        
        for sprite in sprites {
            sprite.update(delta: delta)
            sprite.draw(renderer)
        }

        if (pipes?.isColliding(with:bird!) == true) {
            stop()
        }
        
        particles.update(delta: delta)
        particles.draw(renderer)
    }

}