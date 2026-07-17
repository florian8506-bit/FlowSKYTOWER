extends Node2D

const TOTAL := 70
const VIEW_W := 540.0
const VIEW_H := 960.0

@onready var player: Node2D = $World/Player
@onready var effects: Node2D = $Effects
@onready var progress_label: Label = $UI/TopPanel/Progress
@onready var combo_label: Label = $UI/TopPanel/Combo
@onready var status_label: Label = $UI/Status
@onready var event_card: ColorRect = $UI/EventCard
@onready var event_text: Label = $UI/EventCard/EventText
@onready var audio_positive: AudioStreamPlayer = $AudioPositive
@onready var audio_attack: AudioStreamPlayer = $AudioAttack

var level := 0
var combo := 0
var platforms: Array[Dictionary] = []
var scroll_y := 0.0
var target_scroll_y := 0.0
var time := 0.0
var event_tween: Tween

func _ready() -> void:
	randomize()
	_build_platforms()
	_refresh_ui()
	queue_redraw()

func _build_platforms() -> void:
	platforms.clear()
	for i in TOTAL + 1:
		var zig := sin(float(i) * 1.31) * 112.0
		var x := VIEW_W * 0.5 + zig
		var y := 820.0 - float(i) * 77.0
		var width := 124.0 + sin(float(i) * 0.77) * 22.0
		platforms.append({"x": x, "y": y, "w": width, "special": i % 7 == 0})

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.keycode == KEY_1:
		_apply_gift(1, "Rose", false)
	elif event.keycode == KEY_2:
		_apply_gift(5, "Boost", false)
	elif event.keycode == KEY_3:
		_apply_gift(-3, "Attaque", true)
	elif event.keycode == KEY_4:
		_apply_gift(12, "Super cadeau", false)
	elif event.keycode == KEY_R:
		_reset_game()

func _process(delta: float) -> void:
	time += delta
	scroll_y = lerpf(scroll_y, target_scroll_y, 1.0 - exp(-delta * 6.0))
	if effects.shake_strength > 0.0:
		position = Vector2(randf_range(-effects.shake_strength, effects.shake_strength), randf_range(-effects.shake_strength, effects.shake_strength))
	else:
		position = position.lerp(Vector2.ZERO, minf(1.0, delta * 14.0))
	_update_player_position()
	queue_redraw()

func _apply_gift(amount: int, gift_name: String, attack: bool) -> void:
	var old_level := level
	level = clampi(level + amount, 0, TOTAL)
	if attack:
		combo = 0
		player.hit()
		audio_attack.play()
	else:
		combo += max(1, amount)
		player.celebrate()
		audio_positive.pitch_scale = randf_range(0.94, 1.08)
		audio_positive.play()
	target_scroll_y = maxf(0.0, float(level - 5) * 77.0)
	var player_pos := _screen_position_for_level(level)
	effects.burst(player_pos, 36 if abs(amount) >= 10 else 18, attack)
	_show_event("Viewer_test a envoye : %s (%+d)" % [gift_name, amount])
	_refresh_ui()
	if level == TOTAL and old_level != TOTAL:
		status_label.text = "SOMMET ATTEINT !"

func _reset_game() -> void:
	level = 0
	combo = 0
	target_scroll_y = 0.0
	status_label.text = "MODE TEST - cadeaux simules"
	player.position = _screen_position_for_level(0)
	_show_event("Partie recommencee")
	_refresh_ui()

func _refresh_ui() -> void:
	progress_label.text = "%d / %d" % [level, TOTAL]
	combo_label.text = "COMBO x%d" % combo

func _show_event(message: String) -> void:
	event_text.text = message
	event_card.visible = true
	event_card.modulate.a = 0.0
	event_card.scale = Vector2(0.9, 0.9)
	event_card.pivot_offset = event_card.size * 0.5
	if event_tween and event_tween.is_running():
		event_tween.kill()
	event_tween = create_tween()
	event_tween.set_parallel(true)
	event_tween.tween_property(event_card, "modulate:a", 1.0, 0.15)
	event_tween.tween_property(event_card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	event_tween.set_parallel(false)
	event_tween.tween_interval(1.15)
	event_tween.tween_property(event_card, "modulate:a", 0.0, 0.25)
	event_tween.tween_callback(func(): event_card.visible = false)

func _screen_position_for_level(idx: int) -> Vector2:
	var p: Dictionary = platforms[clampi(idx, 0, TOTAL)]
	return Vector2(p.x, p.y + scroll_y - 43.0)

func _update_player_position() -> void:
	var target := _screen_position_for_level(level)
	player.position = player.position.lerp(target, 0.18)

func _draw() -> void:
	_draw_background()
	_draw_platforms()
	_draw_foreground_glow()

func _draw_background() -> void:
	draw_rect(Rect2(0, 0, VIEW_W, VIEW_H), Color("07152f"), true)
	for i in 9:
		var radius := 520.0 - float(i) * 52.0 + sin(time * 0.8 + i) * 7.0
		var alpha := 0.018 + float(i) * 0.002
		draw_circle(Vector2(270, 490), radius, Color(0.05, 0.55, 0.95, alpha))
	for i in 34:
		var sx := fmod(float(i * 97), VIEW_W)
		var sy := fmod(float(i * 151) + time * (8.0 + float(i % 5)), VIEW_H)
		draw_circle(Vector2(sx, sy), 1.0 + float(i % 3), Color(0.55, 0.88, 1.0, 0.35))
	draw_circle(Vector2(78, 240), 105, Color(0.1, 0.48, 0.9, 0.12))
	draw_circle(Vector2(465, 390), 150, Color(0.35, 0.12, 0.8, 0.1))

func _draw_platforms() -> void:
	for i in platforms.size():
		var p: Dictionary = platforms[i]
		var y: float = p.y + scroll_y
		if y < 155.0 or y > 810.0:
			continue
		var center := Vector2(p.x, y)
		var w: float = p.w
		var special: bool = p.special
		var pulse := (sin(time * 3.5 + float(i)) + 1.0) * 0.5
		var glow := Color(1.0, 0.52, 0.08, 0.18 + pulse * 0.10) if special else Color(0.0, 0.75, 1.0, 0.14 + pulse * 0.08)
		draw_rect(Rect2(center.x - w * 0.58, center.y - 10, w * 1.16, 27), glow, true)
		var body := Color("ff9f28") if special else Color("1bc6ef")
		draw_rect(Rect2(center.x - w * 0.5, center.y - 7, w, 18), body, true)
		draw_rect(Rect2(center.x - w * 0.5, center.y - 7, w, 4), body.lightened(0.35), true)
		draw_line(Vector2(center.x - w * 0.5, center.y + 11), Vector2(center.x + w * 0.5, center.y + 11), body.darkened(0.55), 3.0)
		if i == level:
			draw_arc(center + Vector2(0, -19), 18.0 + pulse * 5.0, 0, TAU, 32, Color(0.6, 1.0, 0.4, 0.75), 3.0)

func _draw_foreground_glow() -> void:
	draw_rect(Rect2(0, 780, VIEW_W, 180), Color(0.01, 0.03, 0.08, 0.3), true)
