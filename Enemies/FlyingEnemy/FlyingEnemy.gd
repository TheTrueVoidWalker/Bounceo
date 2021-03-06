extends "../EnemyBase.gd"

export (int) var move_speed = 150
export (bool) var start_right = false

func _ready():
	max_move_speed = move_speed
	max_jump_speed = 0
	health = 1
	velocity.x = move_speed
	damage = 1
	if not start_right:
		velocity.x = -velocity.x

func hurt():
	.hurt()
	set_collision_layer_bit(2, false)
	$Animation.play("flash")
	$ImmunityTimer.start()

func _on_ImmunityTimer_timeout():
	$Animation.stop()
	$Animation.play("default")
	set_collision_layer_bit(2, true)

func collide_with_player():
	position = pPosition

func collide_with_wall():
	velocity = -velocity




