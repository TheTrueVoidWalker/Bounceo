extends KinematicBody2D

export (int) var max_run_speed = 300
export (int) var jump_speed = 400
export (float) var acceleration = 0.25
export (float) var deacceleration = 0.05
export (int) var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var pPosition := position
var velocity := Vector2()
var pVelocity := velocity
var bounceLimited := 0.0

var FLAG_DAMAGE_TIMEOUT := false

func _ready():
	$Sprite.play("default")

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
	if velocity.y >= 0 or velocity.length() < 0.1*gravity or position.y > collision.collider.position.y:
		hurt()
	else:
		collision.collider.hurt()
	#Bounce player away from enemy
	velocity = pVelocity
	position = pPosition
	velocity = (2*velocity).bounce(collision.normal)
	bounceLimited = 0.1
	#Prevent enemy collisions for a short while to prevent blockage/wierd behavior
	$EnemyHitTimer.start()
	

func _on_DamageTimer_timeout():
	FLAG_DAMAGE_TIMEOUT = true
	$Sprite.play("default")

func _on_EnemyHitTimer_timeout():
	pass

func _physics_process(delta):
	#Handle flags
	bounceLimited -= delta
	bounceLimited = max(bounceLimited, 0)
	if FLAG_DAMAGE_TIMEOUT:
		set_collision_mask_bit(2, true)
		FLAG_DAMAGE_TIMEOUT = false
	#Handle motion
	get_input_acceleration()
	if is_on_floor():
		velocity.y = -jump_speed
	if is_on_wall():
		velocity.x = -pVelocity.x
		bounceLimited = 0.1
	if is_on_ceiling():
		velocity.y = -pVelocity.y
	velocity.y += gravity * delta
	#Handle collisions
	for i in range(get_slide_count()):
		if "Enemy" in get_slide_collision(i).collider.name:
			collided_with_enemy(get_slide_collision(i))
	#Move
	velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	velocity.y = clamp(velocity.y, -jump_speed, jump_speed)
	pPosition = position
	pVelocity = velocity
	velocity = move_and_slide(velocity, Vector2(0, -1))
