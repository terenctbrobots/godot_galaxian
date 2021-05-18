extends Area2D

export var speed = 400


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	position += Vector2(0,1) * speed * delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Enemy_Missile_body_entered(body):
	print("player hit")
	


func _on_Enemy_Missile_area_entered(area):
	print("Player hit")
