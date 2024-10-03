class_name FlowUnit
extends RigidBody2D

var velocity: Vector2 = Vector2.ZERO
var speed: float = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if(velocity != Vector2.ZERO):
		#move_and_collide(velocity * speed * delta)
		linear_velocity = velocity * speed
	#move_toward(velocity * speed * delta)
