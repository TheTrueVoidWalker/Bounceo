extends KinematicBody2D

export (int) var max_run_speed = 300
export (int) var jump_speed = 400
export (float) var acceleration = 0.25
export (float) var deacceleration = 0.05
export (int) var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
export (Vector2) var vertical = Vector2(0,-1)

var velocity := Vector2()
var collision : KinematicCollision2D

var bounceLimited := 0.0
var FLAG_DAMAGE_TIMEOUT := false

func _ready():
	$Sprite.play("default")
	#Set up camera
	var used_rect = get_parent().get_node("Map").get_used_rect()
	var cell_size = get_parent().get_node("Map").cell_size
	$Camera.limit_left = used_rect.position.x*cell_size.x
	$Camera.limit_right = used_rect.end.x*cell_size.x
	$Camera.limit_top = used_rect.position.y*cell_size.x
	$Camera.limit_bottom = used_rect.end.y*cell_size.x

func get_input_acceleration():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	if right and not left and not bounceLimited:
		velocity.x = lerp(velocity.x, max_run_speed, acceleration)
	if left and not right and not bounceLimited:
		velocity.x = lerp(velocity.x, -max_run_speed, acceleration)
	if not (left or right) or (left and right):
		velocity.x = lerp(velocity.x, 0, deacceleration)

func hurt():
	set_collision_mask_bit(2, false)
	$Sprite.play("Hurt")
	$DamageTimer.start()

func collided_with_enemy(collision):
	#Determine if player damaged or enemy defeated
	if velocity.y >= 0 or not abs(velocity.angle_to(global_position-collision.position)) < PI/4:
		hurt()
	else:
		collision.collider.hurt()
		
func _on_DamageBox_body_entered(body):
	if "Enemy" in body.name:
		body.damageable = true


func _on_DamageBox_body_exited(body):
	if "Enemy" in body.name:
		body.damageable = false

func _on_DamageTimer_timeout():
	if collision and "Enemy" in collision.collider.name:
		hurt()
	else:
		set_collision_mask_bit(2, true)
	$Sprite.play("default")

func _physics_process(delta):
	#Handle flags
	bounceLimited -= delta
	bounceLimited = max(bounceLimited, 0)
	#Handle motion
	get_input_acceleration()
	velocity.y += gravity*delta
	#Handle collisions
	if collision:
		velocity = velocity.bounce(collision.normal)
		if abs(collision.normal.angle_to(vertical)) < PI / 6:
			#Bounced off of floor
			velocity.y = -jump_speed
		elif not abs(collision.normal.angle_to(vertical.rotated(PI))) < PI / 6:
			#Bounced off of wall
			bounceLimited = 0.1
		if "Enemy" in collision.collider.name:
			collided_with_enemy(collision)
	#Move
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	velocity.y = clamp(velocity.y, -jump_speed, jump_speed)
	collision = move_and_collide(velocity*delta)
