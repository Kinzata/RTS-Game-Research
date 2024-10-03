extends Node2D

class_name State

signal transitioned(state: State, new_state_name: String, data: Variant)

func enter(data: Variant):
	pass
	
func exit():
	pass
	
func update(delta: float):
	pass
	
func physics_update(delta: float):
	pass
