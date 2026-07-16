extends Node2D

const VIEW_SIZE := Vector2(540, 960)
const PLATFORM_COUNT := 18

var progress := 0
var combo := 0
var player_y := 770.0
var target_y := 770.0
var shake_time := 0.0

func _ready() -> void:
    get_viewport().size = Vector2i(int(VIEW_SIZE.x), int(VIEW_SIZE.y))
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    player_y = lerp(player_y, target_y, min(delta * 7.0, 1.0))
    if shake_time > 0.0:
        shake_time -= delta
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_1:
                apply_gift(1, "ROSE")
            KEY_2:
                apply_gift(5, "BOOST")
            KEY_3:
                apply_gift(-3, "ATTAQUE")
            KEY_4:
                apply_gift(12, "SUPER")
            KEY_R:
                reset_run()

func apply_gift(amount: int, _gift_name: String) -> void:
    progress = clamp(progress + amount, 0, 70)
    combo = max(combo + 1, 0) if amount > 0 else 0
    target_y = 770.0 - float(progress) * 8.2
    if amount < 0:
        shake_time = 0.35

func reset_run() -> void:
    progress = 0
    combo = 0
    target_y = 770.0

func _draw() -> void:
    var offset := Vector2.ZERO
    if shake_time > 0.0:
        offset = Vector2(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0))

    draw_rect(Rect2(Vector2.ZERO, VIEW_SIZE), Color("091225"))

    # Sky glow
    for i in range(8):
        draw_circle(Vector2(270, 250), 360.0 - i * 35.0, Color(0.06, 0.18, 0.35, 0.09))

    # Tower platforms
    for i in range(PLATFORM_COUNT):
        var y := 820.0 - i * 43.0
        var x := 270.0 + sin(float(i) * 0.8) * 72.0
        var w := 180.0 - float(i % 3) * 18.0
        var rect := Rect2(Vector2(x - w / 2.0, y), Vector2(w, 24))
        var c := Color("183a68") if i % 4 != 0 else Color("ff7a45")
        draw_rect(Rect2(rect.position + offset + Vector2(0, 5), rect.size), Color(0,0,0,0.28), true)
        draw_rect(Rect2(rect.position + offset, rect.size), c, true)
        draw_line(rect.position + offset, rect.position + offset + Vector2(w,0), Color("7ad8ff"), 2.0)

    # Player
    var p := Vector2(270, player_y) + offset
    draw_circle(p, 24, Color("f1f7ff"))
    draw_rect(Rect2(p + Vector2(-18, 20), Vector2(36, 48)), Color("dfe9f5"), true)
    draw_circle(p + Vector2(-9,-4), 3, Color("10233e"))
    draw_circle(p + Vector2(9,-4), 3, Color("10233e"))

    # HUD
    draw_rect(Rect2(18, 18, 504, 112), Color(0.03,0.08,0.16,0.93), true)
    draw_line(Vector2(18,130), Vector2(522,130), Color("38d7ff"), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(34, 52), "FLOW SKY TOWER", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(34, 101), str(progress) + " / 70", HORIZONTAL_ALIGNMENT_LEFT, -1, 40, Color("93ff5c"))
    draw_string(ThemeDB.fallback_font, Vector2(380, 91), "COMBO x" + str(combo), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("ffd15c"))

    # Test buttons
    var labels := ["1  ROSE +1", "2  BOOST +5", "3  ATTAQUE -3", "4  SUPER +12", "R  RESET"]
    for i in range(labels.size()):
        var yy := 735.0 + i * 40.0
        draw_rect(Rect2(24, yy, 492, 32), Color(0.04,0.08,0.15,0.88), true)
        draw_string(ThemeDB.fallback_font, Vector2(42, yy + 23), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
