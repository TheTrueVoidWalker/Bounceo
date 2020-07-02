extends Control

func _ready():
	get_tree().paused = false

func _on_Start_pressed():
	SceneChanger.change_scene("res://Levels/Debug Level.tscn", 0)

func _on_Quit_pressed():
	get_tree().quit(0)
