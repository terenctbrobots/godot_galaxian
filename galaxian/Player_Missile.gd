extends Area2D

var speed = 400
var _fire = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func fire():
	get_parent().add_child(self)
	_fire = true
	

func _process(delta):
	if !_fire :
		return
		
	position  += Vector2(0,-1) * delta * speed

	if global_position.y < 0:
		queue_free()
