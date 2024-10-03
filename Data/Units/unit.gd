class_name Unit

extends AnimatableBody2D

@onready var state_machine: StateMachine = $StateMachine
@onready var team_component = $TeamComponent
@onready var animation_player : UnitAnimationPlayer = $UnitAnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var selected_sprite: Sprite2D = $SelectedSprite
@onready var movement_component: MovementComponent  = $MovementComponent
@onready var awareness_component: AwarenessComponent = $AwarenessComponent

var velocity: Vector2 = Vector2.ZERO
var _old_velocity: Vector2 = Vector2.ZERO
@export var team_string: String

@export var unit_data: UnitData

var unit_state = UnitStates.Idle
var is_selected = false
var target_enemy: WeakRef

var attack_range: float = 40
var attack_power: int = 4
var speed: float = 75
 
signal on_select
signal on_deselect

enum UnitStates { Moving, Idle, Attacking, Chasing }

func _init(data: UnitData = null):
	if data:
		attack_range = data.range
		attack_power = data.attack_damage
		speed = data.speed
		animation_player.add_animation_library("Unit", data.animation_library)
		animated_sprite_2d.sprite_frames = data.sprite_frames

# Called when the node enters the scene tree for the first time.
func _ready():
	attack_range = unit_data.range
	attack_power = unit_data.attack_damage
	speed = unit_data.speed
	animation_player.add_animation_library("Unit", unit_data.animation_library)
	animated_sprite_2d.sprite_frames = unit_data.sprite_frames
	
	add_to_group(team_string)
	selected_sprite.hide()
	enter_idle()
	
	for child in find_children("MovementComponent"):
		if child is MovementComponent:
			child.path_created.connect(on_handle_path_created)
			child.position_reached.connect(on_handle_position_reached)

func _process(delta):
	if velocity != _old_velocity:
		handle_velocity_changed()
	
	if _should_be_attacking():
		enter_attack(target_enemy.get_ref())
		
# Called from animation player
func _do_attack():
	if(target_enemy and target_enemy.get_ref() and unit_state == UnitStates.Attacking):
		var enemy_health_component = target_enemy.get_ref().find_child("HealthComponent") as HealthComponent
		if( enemy_health_component ):
			enemy_health_component.damage(attack_power)

func is_in_range(pos: Vector2) -> bool:
	return position.distance_to(pos) <= attack_range
	
func assign_new_enemy() -> bool:
	if(not awareness_component):
		return false
	var enemy = awareness_component.check_for_enemies()
	if enemy:
		target_enemy = weakref(enemy)
		return true
	else:
		target_enemy = null
		return false
	
func _should_be_attacking() -> bool:
	if(target_enemy and target_enemy.get_ref()):
		var enemy = target_enemy.get_ref() as Unit
		return is_in_range(enemy.position) and unit_state != UnitStates.Attacking
	else:
		return false

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		move_and_collide(velocity * speed * delta)

func handle_velocity_changed():
	_old_velocity = velocity
	if velocity != Vector2.ZERO:
		unit_state = UnitStates.Moving
		animation_player.set_moving(velocity)
	else:
		if( unit_state == UnitStates.Moving):
			debounce_idle()

func move_to(target_pos: Vector2):
	var data := MovingStateData.new(target_pos)
	if(state_machine):
		state_machine.state_override("MovingState", data)
	else:
		movement_component.move_to_position(target_pos)

func on_handle_position_reached():
	if(target_enemy or assign_new_enemy()):
		enter_chase(target_enemy.get_ref())
	else:
		velocity = Vector2.ZERO
		debounce_idle()

func on_handle_path_created(target_pos: Vector2):
	# Play an audio?
	pass
	
func select():
	is_selected = true
	selected_sprite.show()
	on_select.emit()
	awareness_component.check_for_enemies()

func deselect():
	is_selected = false
	selected_sprite.hide()
	on_deselect.emit()

func _on_awareness_component_enemy_entered_awareness_range(enemy_unit: Unit):
	if(not target_enemy or not target_enemy.get_ref()):
		target_enemy = weakref(enemy_unit)
		
	if( unit_state == UnitStates.Idle):
		target_enemy =  weakref(enemy_unit)
		enter_chase(enemy_unit)
		
func _on_attacking_state_target_updated(enemy_unit: Unit):
	if( enemy_unit ):
		target_enemy = weakref(enemy_unit)
	else:
		var enemy = awareness_component.check_for_enemies()
		if enemy:
			target_enemy = weakref(enemy)
		else:
			enter_idle()
	if( target_enemy ):
		enter_chase(target_enemy.get_ref())
	else:
		enter_idle()

#region State Change
func enter_idle():
	if(target_enemy):
		enter_chase(target_enemy.get_ref())
	else:
		unit_state = UnitStates.Idle
		animation_player.set_idle()
		state_machine.state_override("IdleState",{})

func debounce_idle():
	unit_state = UnitStates.Idle
	await get_tree().create_timer(0.25).timeout
	if( unit_state == UnitStates.Idle ):
		enter_idle()
	
func enter_chase(target: Unit):
	if(target == null):
		target_enemy = null
		return
	unit_state = UnitStates.Chasing
	state_machine.state_override("ChasingState", ChasingStateData.new(target))
	
func enter_attack(target: Unit):
	if(target == null):
		target_enemy = null
		return
	velocity = Vector2.ZERO
	unit_state = UnitStates.Attacking
	state_machine.state_override("AttackingState", AttackingStateData.new(target))
	animation_player.set_attacking(target.position - position)
#endregion
