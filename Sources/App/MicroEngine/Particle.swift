import SwiftMath

import emsdk

class Particle {
    var position: vec2
    var velocity: vec2
    var color: vec3
    var size: Float
    var life: Float
    var maxLife: Float
    
    init(position: vec2, velocity: vec2, color: vec3, size: Float, life: Float) {
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.life = life
        self.maxLife = life
    }
    
    func update(delta: Double) -> Bool {
        position = position + velocity * Float(delta)
        life -= Float(delta)
        return life > 0
    }
}

class ParticleSystem {
    private var particles: [Particle] = []
    private let maxParticles: Int
    
    // Rainbow colors
    private let colors: [vec3] = [
        vec3(1, 0, 0),    // Red
        vec3(1, 0.5, 0),  // Orange
        vec3(1, 1, 0),    // Yellow
        vec3(0, 1, 0),    // Green
        vec3(0, 0, 1),    // Blue
        vec3(0.5, 0, 1)   // Purple
    ]
    
    init(maxParticles: Int = 1000) {
        self.maxParticles = maxParticles
    }
    
    func emit(at position: vec2) {
        guard particles.count < maxParticles else { return }
        
        // Create particles in a cone shape behind the character
        let baseAngle = Float.pi // Base angle pointing left (behind character)
        let spreadAngle: Float = Float.pi/4 // 45 degree spread
        
        // Emit multiple particles at once for fuller effect
        for _ in 0...50 {
            let angle = baseAngle + Float.random(in: -spreadAngle...spreadAngle)
            let speed = Float.random(in: 100...200)
            let velocity = vec2(cosf(angle), sinf(angle)) * speed
            
            // Cycle through colors in order for rainbow effect
            let colorIndex = (particles.count / 3) % colors.count
            let color = colors[colorIndex]
            
            let size = Float.random(in: 3...6)
            let life = Float.random(in: 0.3...0.6) // Shorter life for better streaming effect
            
            // Offset position slightly for wider trail
            let offset = vec2(0, Float.random(in: -5...5))
            
            particles.append(Particle(
                position: position + offset,
                velocity: velocity,
                color: color,
                size: size,
                life: life
            ))
        }
    }
    
    func update(delta: Double) {
        particles.removeAll { !$0.update(delta: delta) }
    }
    
    func draw(_ renderer: SpriteRenderer) {
        for particle in particles {
            let alpha: Float = particle.life / particle.maxLife
            renderer.drawPoint(at: particle.position,
                             size: particle.size,
                             color: particle.color,
                             alpha: alpha)
        }
    }
}

