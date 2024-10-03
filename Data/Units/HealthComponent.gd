extends Node2D

class_name HealthComponent

var unit: Unit
var max_health: int = 10
var health: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	unit = owner
	max_health = unit.unit_data.health
	health = unit.unit_data.health

func damage(amount: int):
	health = health - amount
	if(health <= 0):
		unit.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
