extends Control

var hearts : int setget set_hearts
var maxHearts : int setget set_max_hearts

var breakingEffect := load("res://Effects/BreakingHeart.tscn")
var formingEffect := load("res://Effects/FormingHeart.tscn")

var textureSize : Vector2

func set_hearts(amount):
	amount = min(amount, maxHearts)
	var pHearts = hearts
	hearts = amount
	var effect : Node
	if hearts <= pHearts:
		$Full.rect_size.x = hearts*textureSize.x
		for i in range(hearts, pHearts):
			effect.position = Vector2((0.5+i)*textureSize.x, 0.5*textureSize.y)
			effect = breakingEffect.instance()
			add_child(effect, true)
	else:
		for i in range(pHearts, hearts):
			effect = formingEffect.instance()
			effect.position = Vector2((0.5+i)*textureSize.x, 0.5*textureSize.y)
			add_child(effect, true)
		yield(effect, "done")
		$Full.rect_size.x = hearts*textureSize.x

func set_max_hearts(amount):
	maxHearts = amount
	set_hearts(clamp(hearts, 0, maxHearts))

func _ready():
	maxHearts = PlayerStats.maxHealth
	hearts = PlayerStats.health
	textureSize = $Full.texture.get_size()
	$Full.rect_size.y = textureSize.y
	$Full.rect_size.x = hearts*textureSize.x
	PlayerStats.connect("updated_health", self, "set_hearts")
