extends Node2D

var bob_time := 0.0
var flash := 0.0

func _process(delta: float) -> void:
    bob_time += delta
    flash = maxf(0.0, flash - delta * 2.5)
    queue_redraw()

func celebrate() -> void:
    flash = 1.0
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", Vector2(1.28, 0.82), 0.10)
    tween.tween_property(self, "scale", Vector2.ONE, 0.22)

func hit() -> void:
    flash = -1.0
    var tween := create_tween()
    tween.tween_property(self, "rotation", -0.18, 0.07)
    tween.tween_property(self, "rotation", 0.18, 0.09)
    tween.tween_property(self, "rotation", 0.0, 0.10)

func _draw() -> void:
    var bob := sin(bob_time * 3.0) * 3.0
    var glow_color := Color(0.18, 0.9, 1.0, 0.22)
    if flash > 0.0:
        glow_color = Color(0.5, 1.0, 0.35, 0.45)
    elif flash < 0.0:
        glow_color = Color(1.0, 0.2, 0.1, 0.45)
    draw_circle(Vector2(0, 6 + bob), 36.0, glow_color)
    draw_circle(Vector2(0, -13 + bob), 17.0, Color(0.78, 0.9, 1.0))
    draw_circle(Vector2(-6, -16 + bob), 2.6, Color(0.04, 0.12, 0.22))
    draw_circle(Vector2(6, -16 + bob), 2.6, Color(0.04, 0.12, 0.22))
    draw_rect(Rect2(-14, 3 + bob, 28, 34), Color(0.45, 0.78, 0.95), true)
    draw_rect(Rect2(-22, 7 + bob, 8, 25), Color(0.62, 0.86, 1.0), true)
    draw_rect(Rect2(14, 7 + bob, 8, 25), Color(0.62, 0.86, 1.0), true)
    draw_rect(Rect2(-12, 37 + bob, 9, 14), Color(0.3, 0.62, 0.85), true)
    draw_rect(Rect2(3, 37 + bob, 9, 14), Color(0.3, 0.62, 0.85), true)
