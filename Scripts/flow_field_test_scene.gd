extends Node2D

@onready var tile_map = $TileMap

@export var flow_unit_scene:PackedScene
var unit_array: Array[FlowUnit] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	FlowField.create_cell_grid(tile_map, 0)

func _input(event):
	if(event.is_action_pressed("spawn_units")):
		for i in range(5):
			_spawn_units()
	if(event.is_action_pressed("clear_units")):
		_clear_units()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if( FlowField.flow_target_cell == null):
		return
	for unit in unit_array:
		var cell: FlowFieldCell = FlowField.get_cell_at_world_pos(unit.position)
		var vector = cell.best_vector
		#if(vector != Vector2.ZERO):
		unit.velocity = vector


func _spawn_units():
	var cell_grid = FlowField.cell_grid
	var cell: FlowFieldCell
	while true:
		var x = randi_range(0, cell_grid.size()-1)
		var y = randi_range(0, cell_grid[x].size()-1)
		cell = cell_grid[x][y]
		if( cell != null and cell.cost < 9999 ):
			break
	
	var unit: FlowUnit = flow_unit_scene.instantiate()
	add_child(unit)
	unit_array.append(unit)
	unit.position = cell.world_position
	
func _clear_units():
	for unit in unit_array:
		unit.queue_free()
	unit_array = []
