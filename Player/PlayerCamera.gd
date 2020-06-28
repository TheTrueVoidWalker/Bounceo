extends Camera2D

const VIEW_FACTOR = 0.1
const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0

onready var pCameraPos := get_camera_position()
onready var tween = $ShiftTween

var facing := 0

func check_facing():
	var newFacing = sign(get_camera_position().x - pCameraPos.x)
	if newFacing != 0 and facing != newFacing:
		facing = newFacing
		var targetOffset = get_viewport_rect().size.x*facing*VIEW_FACTOR
		tween.interpolate_property(self, "position:x", position.x, targetOffset, SHIFT_DURATION, SHIFT_TRANS, SHIFT_EASE)
		tween.start()

func _on_Player_updated_grounded(grounded):
	drag_margin_v_enabled = !grounded

func _process(delta):
	check_facing()
	pCameraPos = get_camera_position()
