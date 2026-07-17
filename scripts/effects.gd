extends Node2D

var particles: Array[Dictionary] = []
var shake_strength := 0.0

func burst(at: Vector2, amount: int, attack := false) -> void:
    for i in amount:
        var angle := randf_range(-PI, PI)
        var speed := randf_range(80.0, 260.0)
        particles.append({
            "pos": at,
            "vel": Vector2(cos(angle), sin(angle)) * speed,
            "life": randf_range(0.45, 1.0),
            "max_life": 1.0,
            "size": randf_range(2.0, 7.0),
            "attack": attack
        })
    shake_strength = 11.0 if attack else 5.0

func _process(delta: float) -> void:
    for p in particles:
        p.life -= delta
        p.vel.y += 240.0 * delta
        p.pos += p.vel * delta
    particles = particles.filter(func(p): return p.life > 0.0)
    shake_strength = move_toward(shake_strength, 0.0, 28.0 * delta)
    queue_redraw()

func _draw() -> void:
    for p in particles:
        var alpha: float = clampf(p.life / p.max_life, 0.0, 1.0)
        var c := Color(1.0, 0.25, 0.08, alpha) if p.attack else Color(0.3, 0.95, 1.0, alpha)
        draw_circle(p.pos, p.size, c)
