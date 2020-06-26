extends KinematicBody2D

var max_move_speed : int
var max_jump_speed : int
var health : int

var velocity := Vector2()
var pPosition := position
var collision : KinematicCollision2D

func _ready():
	pass

func hurt():
	health -= 1
	if health <= 0:
		dead()
	
func dead():
	queue_free()
	
func move():
	pass
	
func collide_with_player():
	pass
	
func collide_with_wall():
	pass

func _physics_process(delta):
	move()
	if collision:
		if "Player" in collision.collider.name:
			collide_with_player()
		else:
			collide_with_wall()
	$Sprite.flip_h = velocity.x > 0
	velocity.x = clamp(velocity.x, - max_move_speed, max_move_speed)
	velocity.y = clamp(velocity.y, - max_jump_speed, max_jump_speed)
	pPosition = position
	collision = move_and_collide(velocity*delta)

