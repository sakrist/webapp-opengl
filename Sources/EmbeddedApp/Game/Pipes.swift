
import SwiftMath

class Pipes : Sprite {

    var pipeTop: Image? 
    var pipes: [Sprite] = []

    var framesCount: Int = 0
    let gap: Float = 90 // distance between pipes

    var state: GameState = .start
    var viewSize: vec2 = vec2(0, 0)

    var incrementScore: (() -> Void) = {}

    init(viewSize: vec2) {
        self.viewSize = viewSize
        self.pipeTop = Image.init(name: "toppipe.png")
        super.init(position: vec2(0,0), size: vec2(0,0), rotation: 0.0, image: nil, frames: [])
    }

    override func update(delta: Double) {
        super.update(delta: delta)
        if state != .playing {
            return
        }
        if (framesCount % 100 == 0) {
            if let pipeTop = pipeTop {
                let height = Float(pipeTop.height)
                print("create pipes")
                let random = Float.random(in: 0...1)
                
                let y: Float = -210 * min(random + 0.5, 1.0)
                let y_bot: Float = y + height + gap // 400 - image size of pipe, 
                let pipeTopSprite = Sprite(
                    position: vec2(viewSize.width, y),
                    size: vec2(52, 400), rotation: 180.0, frames: [pipeTop])
                let pipeBotSprite = Sprite(
                    position: vec2(viewSize.width, y_bot),
                    size: vec2(52, 400), rotation: 0.0, frames: [pipeTop])
                pipes.append(pipeTopSprite)
                pipes.append(pipeBotSprite)
            }
        }

        for pipe in pipes {
            pipe.position.x -= 2
            pipe._recalc()
        }

        if pipes.count > 0 && pipes[0].position.x < -52 {
            pipes.removeFirst()
            pipes.removeFirst()
            incrementScore()
        }

        for pipe in pipes {
            pipe.update(delta: delta)
        }

        framesCount += 1
    }

    override func draw(_ renderer: SpriteRenderer) {
        for pipe in pipes {
            renderer.draw(pipe)
        }
        
    }

    func reset() {
        pipes = []
        framesCount = 0
    }

    override func isColliding(with sprite: Sprite) -> Bool {
        for pipe in pipes {
            if pipe.isColliding(with: sprite) {
                return true
            }
        }
        return false
    }
}