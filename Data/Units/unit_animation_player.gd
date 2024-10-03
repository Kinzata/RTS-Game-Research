class_name UnitAnimationPlayer
extends AnimationPlayer

@export var debounce_time := 0.1
var animation_change_debounce := 0.1

func _process(delta):
	animation_change_debounce += delta

func set_moving(dir: Vector2):
	if(animation_change_debounce < debounce_time):
		return
	animation_change_debounce = 0
	
	if(dir.x < 0):
		play("Unit/Moving_Left")
	else:
		play("Unit/Moving_Right")

func set_idle():
	if(animation_change_debounce < debounce_time):
		return
	animation_change_debounce = 0
	play("Unit/Idle")

func set_attacking(dir: Vector2):
	var angle = dir.normalized().angle()
	if(angle < 0):
		if(angle < -PI / 4):
			if(angle > -3 * PI / 4):
				play("Unit/Attack_Up")
			else:
				play("Unit/Attack_Side_Left")
		else:
			play("Unit/Attack_Side_Right")
	else:
		if(angle > PI / 4):
			if(angle < 3 * PI / 4):
				play("Unit/Attack_Down")
			else:
				play("Unit/Attack_Side_Left")
		else:
			play("Unit/Attack_Side_Right")
