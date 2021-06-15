extends Area2D

var _speed = 400
var _screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	_screen_size = get_viewport().size

func _process(delta):
	position += Vector2(0,1) * _speed * delta
	
	if global_position.y > _screen_size.y:
		queue_free()
		
func _on_Enemy_Missile_body_entered():
	print("Missile body entered, destroy")
	queue_free()

func is_enemy():
	return false
