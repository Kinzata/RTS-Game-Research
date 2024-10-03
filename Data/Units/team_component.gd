extends Node

class_name TeamComponent

@export var team: Enums.Team:
	set(value):
		team = value
		
var team_string: String:
	get:
		match team:
			Enums.Team.Blue:
				return "Blue"
			Enums.Team.Purple:
				return "Purple"
			Enums.Team.Red:
				return "Red"
			Enums.Team.Yellow:
				return "Yellow"
		return "none"
