extends Node

signal updated_health(newHealth)
signal updated_max_health(newMaxHealth)
signal out_of_health()

export (int) var maxHealth := 3 setget update_max_health
onready var health := maxHealth  setget update_health

func update_health(newHealth):
	health = newHealth
	emit_signal("updated_health", health)
	if health <= 0:
		health = 0
		emit_signal("out_of_health")

func update_max_health(newMaxHealth):
	maxHealth = newMaxHealth
	health = clamp(health, 0, maxHealth)
	emit_signal("updated_max_health", maxHealth)
	emit_signal("updated_health", health)
