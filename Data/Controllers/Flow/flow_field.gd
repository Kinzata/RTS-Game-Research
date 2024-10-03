extends Node2D

var cell_grid = []

# Debug
var debug : bool = false
var show_cost: bool = true
var show_current_cost: bool = false
var show_vector: bool = false
var default_font: Font
var default_font_size: int

var flow_target_cell: FlowFieldCell

var tile_map: TileMap
var layer_id: int
var dimensions: Vector2i = Vector2i.ZERO

func _ready():
	default_font = ThemeDB.fallback_font
	default_font_size = ThemeDB.fallback_font_size
	
func _input(event):
	#if event.is_action_pressed("left_click"):
		#reset()
		#create_integration_for_pos(get_global_mouse_position())
		#create_flow_field()
		#queue_redraw()
	pass
		

		
func get_cell_at_world_pos(target_pos: Vector2) -> FlowFieldCell:
	var grid_pos = tile_map.local_to_map(target_pos)
	return _get_cell_at_grid_pos(grid_pos)

func create_cell_grid(_tile_map: TileMap, _layer_id: int):
	tile_map = _tile_map
	layer_id = _layer_id
	var tile_array := tile_map.get_used_cells(layer_id)
	dimensions = tile_map.get_used_rect().size
	for x in dimensions.x:
		cell_grid.append([])
		for y in dimensions.y:
			cell_grid[x].append(null)

	for v2i in tile_array:
		var cell = FlowFieldCell.new(v2i, tile_map.map_to_local(v2i))
		var cost = tile_map.get_cell_tile_data(layer_id, v2i).get_custom_data("cost")
		cell.cost = cost if cost else 9999
		cell_grid[v2i.x][v2i.y] = cell
		
func reset():
	dimensions = tile_map.get_used_rect().size
	for x in dimensions.x:
		for y in dimensions.y:
			if cell_grid[x][y] != null :
				cell_grid[x][y].reset()
		
func create_integration_for_pos(target_pos: Vector2):
	var grid_pos = tile_map.local_to_map(target_pos)
	var target_cell = _get_cell_at_grid_pos(grid_pos)
	if( target_cell == null):
		return
	target_cell.best_cost = 0
	flow_target_cell = target_cell
	var queue: Array[FlowFieldCell] = []
	queue.append(target_cell)
	# enqueue the cell, for while queue has cells, pulls cell, get neightbors, calculate cost
	while( queue.size() != 0 ):
		var current_cell: FlowFieldCell = queue.pop_back()
		var neighbor_cells = _get_neighbor_cardinal_cells(current_cell)
		for neighbor in neighbor_cells:
			if(neighbor == null || neighbor.cost == 9999):
				continue
			if neighbor.cost + current_cell.best_cost < neighbor.best_cost:
				neighbor.best_cost = neighbor.cost + current_cell.best_cost
				queue.append(neighbor)

func create_flow_field():
	for x in dimensions.x:
		for y in dimensions.y:
			var cur_cell: FlowFieldCell = cell_grid[x][y]
			if cur_cell == null:
				continue
			
			var best_cost = cur_cell.best_cost
			var neighbors = _get_neighbor_cells(cur_cell)
			
			for neighbor: FlowFieldCell in neighbors:
				if( neighbor == null ):
					continue
				
				if( neighbor.best_cost < best_cost ):
					best_cost = neighbor.best_cost
					cur_cell.best_vector = neighbor.grid_position - cur_cell.grid_position

func _get_neighbor_cardinal_cells(cell: FlowFieldCell) -> Array[FlowFieldCell]:
	return [
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_TOP_SIDE)),
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)),
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)),
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_LEFT_SIDE)),
	]
	
func _get_neighbor_cells(cell: FlowFieldCell) -> Array[FlowFieldCell]:
	return [
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_TOP_SIDE)), # up
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)), # right
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)), # down
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_LEFT_SIDE)), # left
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER)), # down-left
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)), # down-right
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)), # up-left
		_get_cell_at_grid_pos(tile_map.get_neighbor_cell(cell.grid_position, TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER)), # up-right
	]
	
func _get_cell_at_grid_pos(pos: Vector2) -> FlowFieldCell:
	return cell_grid[pos.x][pos.y]

#region Debugging methods
func toggle_debug_enabled():
	debug = not debug
	print("Debug toggled")
	queue_redraw()
		
func toggle_debug_mode():
	if( show_cost ):
		show_cost = false
		show_current_cost = true
		show_vector = false
		print("show_current_cost: on")
	elif( show_current_cost ):
		show_cost = false
		show_current_cost = false
		show_vector = true
		print("show_vector: on")
	elif( show_vector ):
		show_cost = true
		show_current_cost = false
		show_vector = false
		print("show_cost: on")
	queue_redraw()

func _draw():
	if( not debug ):
		return
	if( cell_grid == null ):
		return
	for row in cell_grid:
		for cell: FlowFieldCell in row:
			if( cell == null ):
				continue
			var start = Vector2(cell.world_position.x - 32, cell.world_position.y - 32)
			var end = Vector2(cell.world_position.x + 32, cell.world_position.y + 32)
			draw_rect(Rect2(start,end - start), Color.WHITE, false, 2.0)
			var text = str(cell.grid_position)
			if( show_cost ):
				text = str(cell.cost)
			if( show_current_cost ):
				text = str(cell.best_cost)
			if( show_vector ):
				var target = cell.best_vector
				if( target != Vector2.ZERO ):
					target *= 10
				draw_line(cell.world_position, target + cell.world_position, Color.BLACK, 2.0)
			else:
				draw_string(default_font, Vector2(cell.world_position.x - 16, cell.world_position.y), text, HORIZONTAL_ALIGNMENT_CENTER, -1, default_font_size, Color.BLACK)
	if (flow_target_cell):
		print("draw circle")
		draw_arc(flow_target_cell.world_position, 20, 0, 360, 10, Color.RED)
#endregion
