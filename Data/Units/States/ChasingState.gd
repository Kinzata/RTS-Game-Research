extends State

@onready var movement_component: MovementComponent = $MovementComponent

var target: Unit
var target_pos: Vector2

var time_between_check = 0.1
var time = 0.0

# Called when the node enters the scene tree for the first time.
func enter(data: Variant):
	print("Chasing state enter")
	assert(data is ChasingStateData, "ChasingState needs ChasingStateData input")
	target = data.target
	movement_component.move_to_position(target.position)

func update(delta):
	time += delta
	if(time >= time_between_check):
		time = 0
		if(is_instance_valid(target)):
			movement_component.move_to_position(target.position)
		else:
			movement_component.position_reached.emit()
