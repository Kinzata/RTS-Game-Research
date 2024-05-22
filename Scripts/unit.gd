class_name Unit

extends StaticBody2D
@onready var team_component = $TeamComponent
@onready var unit_animation_controller: UnitAnimationController = $UnitAnimationController
@onready var selected_sprite: Sprite2D = $SelectedSprite
@onready var movement_component: MovementComponent  = $MovementComponent
@export var movement_marker_scene: PackedScene
var movement_marker: Node2D
var velocity: Vector2 = Vector2.ZERO
var team_string: String

@export var sprite_frames: Array[SpriteFrames]

var unit_state = Enums.UnitStates.Idle
var is_selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_color_by_team()
	unit_state = Enums.UnitStates.Idle
	unit_animation_controller.set_state(unit_state, velocity)
	selected_sprite.hide()

func set_color_by_team():
	match team_component.team:
		Enums.Team.Blue:
			add_to_group("Blue")
			unit_animation_controller.sprite_frames = sprite_frames[0]
		Enums.Team.Purple:
			add_to_group("Purple")
			unit_animation_controller.sprite_frames = sprite_frames[1]
	
	unit_animation_controller.play()

func move_to(target_pos: Vector2):
	movement_component.move_to_position(target_pos)

func on_handle_velocity_updated(dir: Vector2):
	velocity = dir
	unit_state = Enums.UnitStates.Moving
	unit_animation_controller.set_state(unit_state, velocity)

func on_handle_position_reached():
	_clear_move_marker()
	
	velocity = Vector2.ZERO
	unit_state = Enums.UnitStates.Idle
	await get_tree().create_timer(0.25).timeout
	if( unit_state == Enums.UnitStates.Idle ):
		unit_animation_controller.set_state(unit_state, velocity)

func on_handle_path_created(target_pos: Vector2):
	# Play an audio?
	_clear_move_marker()
	movement_marker = movement_marker_scene.instantiate() as Node2D
	movement_marker.global_position = target_pos
	add_sibling(movement_marker)
	
func select():
	is_selected = true
	selected_sprite.show()
	
	if( movement_marker != null ):
		movement_marker.show()
	
func deselect():
	is_selected = false
	selected_sprite.hide()
	
	if( movement_marker != null ):
		movement_marker.hide()

func _clear_move_marker():
	if(movement_marker != null):
		movement_marker.queue_free()
