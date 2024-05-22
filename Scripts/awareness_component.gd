extends Area2D

@onready var emote_location: Node2D = $EmoteLocation
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.hide()
	sprite_2d.position = emote_location.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if( body is Unit ):
		if( not body.is_in_group("Blue") ):
			sprite_2d.show()
			await get_tree().create_timer(2).timeout
			sprite_2d.hide()
