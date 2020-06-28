extends KinematicBody2D

signal updated_grounded(grounded)

export (int) var maxRunSpeed = 10 * Globals.TILE_SIZE
export (float) var acceleration = 0.25
export (float) var deacceleration = 0.05
export (float) var airResistance = 0.035
export (Vector2) var vertical = Vector2(0,-1)
export (float) var gravityMultiplier = 1.0
export (float) var jumpHeight = 4.20 * Globals.TILE_SIZE
export (float) var jumpDuration = 0.75

var velocity := Vector2()
var collision : KinematicCollision2D
var gravity : float
var jumpSpeed : float

var bounceLimited := 0.0
var grounded := false
var wasGrounded := false


func _ready():
	#Set up physics
	gravity = 2*jumpHeight/pow(jumpDuration, 2)
	jumpSpeed = sqrt(2*gravity*jumpHeight)
	#Set up animations
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
		if velocity.x >= 0:
			velocity.x = lerp(velocity.x, maxRunSpeed, acceleration)
		else:
			velocity.x = lerp(velocity.x, maxRunSpeed, deacceleration)
	if left and not right and not bounceLimited:
		if velocity.x <= 0:
			velocity.x = lerp(velocity.x, -maxRunSpeed, acceleration)
		else:
			velocity.x = lerp(velocity.x, -maxRunSpeed, deacceleration)
	if not (left or right) or (left and right):
		velocity.x = lerp(velocity.x, 0, airResistance)

func hurt():
	set_collision_mask_bit(2, false)
	$Sprite.play("Hurt")
	$DamageTimer.start()

func collided_with_enemy(collision):
	#Determine if player damaged or enemy defeated
	if velocity.y >= 0 or not abs(velocity.angle_to(global_position-collision.position)) < PI/3:
		hurt()
	else:
		collision.collider.hurt()

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
	wasGrounded = grounded
	grounded = false
	#Handle motion
	get_input_acceleration()
	velocity.y += gravity*delta
	#Handle collisions
	if collision:
		velocity = velocity.bounce(collision.normal)
		if abs(collision.normal.angle_to(vertical)) < PI / 6:
			#Bounced off of floor
			velocity.y = -jumpSpeed
			grounded = true
		elif not abs(collision.normal.angle_to(vertical.rotated(PI))) < PI / 6:
			#Bounced off of wall
			bounceLimited = 0.1
		if "Enemy" in collision.collider.name:
			collided_with_enemy(collision)
	#Update camera
	if grounded != wasGrounded:
		emit_signal("updated_grounded", grounded)
	#Move
	velocity.x = clamp(velocity.x, -2*maxRunSpeed, 2*maxRunSpeed)
	velocity.y = clamp(velocity.y, -2*jumpSpeed, 2*jumpSpeed)
	collision = move_and_collide(velocity*delta)

