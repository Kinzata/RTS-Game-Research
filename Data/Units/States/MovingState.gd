extends State

@onready var movement_component: MovementComponent = $MovementComponent

@export var movement_marker_scene: PackedScene
var movement_marker: Node2D

var target_pos: Vector2

func enter(data: Variant):
	print("MovingState enter")
	assert(data is MovingStateData, "MovingState needs MovingStateData input")
	target_pos = data.target
	movement_component.move_to_position(target_pos)

func transition(state:String, data: Variant):
	transitioned.emit(self, state, data)

func _clear_move_marker():
	if(movement_marker != null):
		movement_marker.queue_free()
		
func _on_movement_component_position_reached():
	_clear_move_marker()

func _on_movement_component_path_created(vector):
	_clear_move_marker()
	movement_marker = movement_marker_scene.instantiate() as Node2D
	get_tree().root.add_child(movement_marker)
	movement_marker.global_position = target_pos

func hide_movement_marker():
	if( movement_marker != null ):
		movement_marker.hide()

func show_movement_marker():
	if( movement_marker != null ):
		movement_marker.show()
