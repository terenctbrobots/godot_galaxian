extends RigidBody2D

var speed = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fire():
	linear_velocity = Vector2(0,-speed)
	
func _physics_process(delta):
	if global_position.y < 0:
		queue_free()
