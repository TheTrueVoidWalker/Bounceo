extends CanvasLayer

signal scene_changed()

onready var animation = $Animation
onready var black = $Control/Black

func change_scene(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animation.play("fade")
	yield(animation, "animation_finished")
	assert(get_tree().change_scene(path) == OK)
	animation.play_backwards("fade")
	yield(animation, "animation_finished")
	emit_signal("scene_changed")
