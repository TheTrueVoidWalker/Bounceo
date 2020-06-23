extends KinematicBody2D

export (int) var move_speed = 150
export (bool) var start_right = false

var pPosition := position
var velocity := Vector2()
var pVelocity := velocity
var collision : KinematicCollision2D

func _ready():
	velocity.x = move_speed
	if not start_right:
		velocity.x = -velocity.x
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		
func hurt():
	set_collision_layer_bit(2, false)
	$Sprite.play("Hurt")
	$HurtByPlayerTimer.start()

func _on_HurtByPlayerTimer_timeout():
	$Sprite.play("default")
	set_collision_layer_bit(2, true)

func _physics_process(delta):
	if collision:
		position = pPosition
		if "Player" in collision.collider.name:
			velocity = pVelocity
		else:
			velocity = -pVelocity
	$Sprite.flip_h = velocity.x > 0
	pPosition = position
	pVelocity = velocity
	collision = move_and_collide(velocity*delta)

