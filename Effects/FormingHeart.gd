extends Node2D

signal done()

func _ready():
	$Animation.play("show")

func _on_Sprite_animation_finished():
	emit_signal("done")
	queue_free()

func _on_Animation_animation_finished(anim_name):
	$Sprite.play("default")
	
