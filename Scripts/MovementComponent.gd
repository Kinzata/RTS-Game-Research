class_name MovementComponent

extends Node2D

@export var speed := 50
var click_position = Vector2(0, 0)

var is_moving := false
var is_holding := false
var is_navigation_ready := false

var hold_position_pos := Vector2(0, 0)
var velocity_emit_counter := 0.25
var current_nav_vector_target := Vector2(0, 0)
var movement_direction: Vector2:
	get:
		return (current_nav_vector_target - global_position).normalized()

@onready var unit: Unit = $".."
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var boid_collision_area: Area2D = $BoidCollisionArea

signal velocity_updated(Vector2)
signal position_reached()
signal path_created(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	click_position = Vector2(global_position.x, global_position.y)
	current_nav_vector_target = click_position
	navigation_agent_2d.set_navigation_map(get_world_2d().navigation_map)
	hold_position_pos = global_position
	call_deferred("_setup")

func _setup():
	await get_tree().physics_frame
	is_navigation_ready = true
	navigation_agent_2d.target_position = global_position

func move_to_position(pos: Vector2):
	var distance := global_position.distance_to(pos)

	if (distance >= 3):
		navigation_agent_2d.target_position = pos
		path_created.emit(pos)
		is_holding = false
		_set_navigation_path()

func _set_navigation_path():
	current_nav_vector_target = navigation_agent_2d.get_next_path_position()
	if( velocity_emit_counter > 0.25 ):
		velocity_updated.emit(movement_direction)
		velocity_emit_counter = 0.0
	is_moving = true
	
func _process(delta):
	velocity_emit_counter += delta

func _physics_process(delta):
	var movement_vector = Vector2.ZERO
	
	if( is_navigation_ready and not navigation_agent_2d.is_navigation_finished() ):
		_set_navigation_path()
		movement_vector += movement_direction # movement weight
		
	elif( boid_collision_area.has_overlapping_areas() ):
		var near_areas = boid_collision_area.get_overlapping_areas()
		var close_d = Vector2.ZERO
		for avoid in near_areas:
			close_d.x += global_position.x - avoid.global_position.x
			close_d.y += global_position.y - avoid.global_position.y
		movement_vector += close_d.normalized() + _get_noise()
		if( velocity_emit_counter > 0.25 ):
			velocity_updated.emit(movement_vector)
			velocity_emit_counter = 0.0
		is_moving = true
		
	if( movement_vector != Vector2.ZERO ):
		unit.move_and_collide(movement_vector.normalized() * speed * delta)
	elif(is_moving):
		is_moving = false
		if(is_holding):
			navigation_agent_2d.target_position = hold_position_pos
		else:
			is_holding = true
			hold_position_pos = global_position
		position_reached.emit()
		
func _get_noise():
	return Vector2(randf_range(-0.1,0.1), randf_range(-0.1,0.1))
