extends Area2D

export var speed = 400

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size

func _process(delta):
	position += Vector2(0,1) * speed * delta
	
	if global_position.y > screen_size.y:
		queue_free()
		
func _on_Enemy_Missile_body_entered():
	print("Missile body entered, destroy")
	queue_free()
