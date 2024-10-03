class_name FlowFieldCell

var grid_position: Vector2i
var world_position: Vector2
var cost : int = 0
var best_cost : int = 9998

var best_vector : Vector2 = Vector2.ZERO


func _init(_grid_position: Vector2, _world_position: Vector2):
	grid_position = _grid_position
	world_position = _world_position

func reset():
	best_cost = 9998
	best_vector = Vector2.ZERO
