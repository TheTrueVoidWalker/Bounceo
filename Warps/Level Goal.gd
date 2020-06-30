extends Area2D

func _on_Level_Goal_body_entered(body):
	body.reached_goal()
