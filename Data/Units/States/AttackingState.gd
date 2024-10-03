extends State

signal target_updated(unit: Unit)

var unit: Unit
var target: Unit

var time_between_check = 0.1
var time = 0.0

func _ready():
	unit = owner

func enter(data: Variant):
	print("Attacking state enter")
	assert(data is AttackingStateData, "AttackingState needs AttackingStateData input")
	target = data.target

func update(delta):
	if target and is_instance_valid(target):
		if not is_in_range(target.position):
			var data = ChasingStateData.new(target)
			target_updated.emit(target)
	else:
		target_updated.emit(null)

func is_in_range(pos: Vector2) -> bool:
	return unit.position.distance_to(pos) <= unit.attack_range
