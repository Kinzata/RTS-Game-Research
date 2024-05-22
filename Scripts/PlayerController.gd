extends Node2D

var team: Enums.Team = Enums.Team.Blue

var selected_units: Array = []
var dragging := false
var movement := false
var drag_start_pos := Vector2.ZERO
var drag_end_pos := Vector2.ZERO

@export var time_between_curve_points := 0.05
var t_curve := 0.0
var curve: Curve2D
var curve_tesselate: PackedVector2Array

@onready var movement_controller: MovementController = $MovementController

func _ready():
	t_curve = time_between_curve_points

func _unhandled_input(event):
	if event is InputEventMouseMotion and dragging:
		# draw box
		queue_redraw()
		
	if event.is_action_pressed("left_click"):
		# start dragging
		dragging = true
		drag_start_pos = get_global_mouse_position()
		
	if event.is_action_released("left_click"):
		# stop dragging
		dragging = false
		queue_redraw()
		drag_end_pos = get_global_mouse_position()
		_query_for_selection()
		
	if event.is_action_pressed("right_click"):
		dragging = true
		movement = true
		t_curve = time_between_curve_points
		curve = Curve2D.new()
		
	if event.is_action_released("right_click"):
		dragging = false
		movement = false
		curve_tesselate = []
		queue_redraw()
		if( selected_units.size() > 0 ):
			var units: Array[Unit] = []
			units.assign(selected_units) # this feels wrong  This is the only way I've figured out to cast arrays, I can't on assignment
			if(curve.point_count > 1):
				movement_controller.send_curve_movement_to_units(units, curve)
			else:
				movement_controller.send_movement_to_units(units, get_global_mouse_position())

func _process(delta):
	if(movement and dragging):
		t_curve += delta
		if(t_curve >= time_between_curve_points):
			curve.add_point(get_global_mouse_position())
			curve_tesselate = curve.tessellate_even_length()
			t_curve = 0

func _query_for_selection():
	for unit in selected_units:
		unit.deselect()
	
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = (drag_end_pos-drag_start_pos).abs()
	
	var space = get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1 # Units are on 1
	query.transform = Transform2D(0, (drag_end_pos + drag_start_pos) / 2)
	selected_units = space.intersect_shape(query) \
		.filter(_unit_selection_filter) \
		.map(func(d): return d.collider)
	for unit in selected_units:
		unit.select()

func _unit_selection_filter(d: Dictionary) -> bool:
	var collider = d.collider
	return collider is Unit and collider.is_in_group("Blue")

func _draw():
	if not movement and dragging:
		draw_rect(Rect2(drag_start_pos, get_global_mouse_position() - drag_start_pos), Color.WHITE, false, 2.0)
		
	if movement and dragging:
		if(curve_tesselate.size() > 1 ):
			var start = curve_tesselate[0]
			for i in range(1, curve_tesselate.size()):
				draw_line(start, curve_tesselate[i], Color.BLUE, 2.0)
				start = curve_tesselate[i]
