extends Node2D

signal done()

func _ready():
	$Sprite.play("default")

func _on_Sprite_animation_finished():
	$Animation.play("fade")

func _on_Animation_animation_finished(anim_name):
	emit_signal("done")
	queue_free()
