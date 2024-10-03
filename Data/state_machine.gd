extends Node

class_name StateMachine

@export var initial_state : State
var current_state : State
var states : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_child_transitioned)
	if initial_state:
		current_state = initial_state
		initial_state.process_mode = Node2D.PROCESS_MODE_INHERIT
		initial_state.enter({})

func _process(delta):
	if current_state:
		current_state.update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

# State transition override for setting a state from parent
func state_override(new_state_name: String, data: Variant):
	var new_state = states[new_state_name.to_lower()]
	if new_state == null:
		return
		
	_transition_to_state(new_state, data)

# Signal hook for transition controlled by current state
func _on_child_transitioned(state: State, new_state_name: String, data: Variant):
	print("Transition from %s to %s" % [state.name, new_state_name])
	if(state != current_state):
		return
	
	var new_state = states[new_state_name.to_lower()]
	if new_state == null:
		return
		
	_transition_to_state(new_state, data)

# Internal state transition function
func _transition_to_state(new_state: State, data: Variant):
	if current_state:
		current_state.exit()
		current_state.process_mode = Node2D.PROCESS_MODE_DISABLED
		
	new_state.process_mode = Node2D.PROCESS_MODE_INHERIT
	new_state.enter(data)
	current_state = new_state
