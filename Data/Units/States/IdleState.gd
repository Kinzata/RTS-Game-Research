extends State

var unit : Unit
@export var boid_collision_area : Area2D

func _ready():
	unit = owner

func transition(state:String, data: Variant):
	transitioned.emit(self, state, data)

func physics_update(delta):
	if( boid_collision_area.has_overlapping_areas() ):
		var near_areas = boid_collision_area.get_overlapping_areas()
		near_areas = near_areas.filter(func(area):
			var x = area.owner
			return area.owner.team_string == unit.team_string
		)
		var close_d = Vector2.ZERO
		for avoid in near_areas:
			close_d.x += global_position.x - avoid.global_position.x
			close_d.y += global_position.y - avoid.global_position.y
		if(near_areas.size() != 0 or close_d != Vector2.ZERO):
			unit.velocity = close_d.normalized() + _get_noise()
	else:
		unit.velocity = Vector2.ZERO

func _get_noise():
	return Vector2(randf_range(-0.1,0.1), randf_range(-0.1,0.1))
