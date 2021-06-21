extends Area2D

signal enemy_hit(enemy)

var _speed = 400
var _fire = false
var _main 

func _ready():	
	_main = get_node("/root").get_child(0)
	
func fire():
	$CollisionShape2D.disabled = false
	_main.add_child(self)
	connect("enemy_hit",_main,"enemy_hit")
	_fire = true
	
func _process(delta):
	if !_fire :
		return
		
	position  += Vector2(0,-1) * delta * _speed

	if global_position.y < 0:
		queue_free()

func _on_Missile_area_entered(area):
	emit_signal("enemy_hit",area)
	queue_free()
