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

var body: Unit
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
#@onready var boid_collision_area: Area2D = $BoidCollisionArea

signal position_reached()
signal path_created(vector: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	body = owner
	assert(body != null, "Body must be a Unit")
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
	navigation_agent_2d.target_position = pos
	path_created.emit(pos)
	is_holding = false
	_set_navigation_path()

func _set_navigation_path():
	current_nav_vector_target = navigation_agent_2d.get_next_path_position()
	
func _process(delta):
	velocity_emit_counter += delta

func _physics_process(delta):
	if( is_navigation_ready and not navigation_agent_2d.is_navigation_finished() ):
		_set_navigation_path()
		body.velocity = movement_direction
	else:
		body.velocity = Vector2.ZERO
		position_reached.emit()
