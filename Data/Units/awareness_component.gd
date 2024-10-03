extends Area2D

class_name AwarenessComponent

var unit : Unit

@onready var emote_location: Node2D = $EmoteLocation
@onready var sprite_2d: Sprite2D = $Sprite2D

signal enemy_entered_awareness_range(Unit)

# Called when the node enters the scene tree for the first time.
func _ready():
	unit = owner
	sprite_2d.hide()
	assert(emote_location != null, "Needs a child Node2D called EmoteLocation for emotes")
	sprite_2d.position = emote_location.position
	
func check_for_enemies() -> Unit:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if( body is Unit ):
			if( not body.is_in_group(unit.team_string) ):
				return body
	return null

func _on_body_entered(body):
	if( body is Unit ):
		if( not body.is_in_group(unit.team_string) ):
			enemy_entered_awareness_range.emit(body)
			sprite_2d.show()
			await get_tree().create_timer(2).timeout
			sprite_2d.hide()
