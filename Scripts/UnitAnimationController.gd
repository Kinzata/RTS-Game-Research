class_name UnitAnimationController

extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	play("Idle")

func set_state(state: Enums.UnitStates, dir: Vector2):
	match state:
		Enums.UnitStates.Moving:
			if(dir.x < 0):
				flip_h = true
			else:
				flip_h = false
			play("Moving")
		Enums.UnitStates.Idle:
			play("Idle")
