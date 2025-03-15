import SwiftMath

class Bird : Sprite {

    var velocity: vec2 = vec2(0, 0)
    var gravity: vec2 = vec2(0, 0.1)
    var thrust:Float = 2.5
    // var frame = 0

    var state: GameState = .start

    var colliders: [Sprite] = []

    var collisioned: (() -> Void)?

    override func update(delta: Double) {
        super.update(delta: delta)

        if (state == .playing) {
            
            self.position.y -= self.velocity.y;
            self.setRotation();
            self.velocity = self.velocity + self.gravity;
            self._recalc()

            let collidersCopy = colliders
            for collider in collidersCopy {
                if self.isColliding(with: collider) {
                    if let collisioned = collisioned {
                        collisioned()
                    }
                    break
                }
            }
        }
    }

    func setRotation() {
        if (self.velocity.y <= 0) {
            self.rotation = max(-25, (-25 * velocity.y) / (-1 * thrust));
        } else if (self.velocity.y > 0) {
            self.rotation = min(90, (90 * velocity.y) / (thrust * 2));
        }
    }

    func flap() {
        velocity = vec2(0, -thrust)
    }

}