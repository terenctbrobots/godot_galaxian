extends Area2D

signal enemy_hit(enemy)

var _speed = 400
var _fire = false
var _main 
var _global_position

func _ready():	
	_main = get_node("/root").get_child(0)
	
func fire():
	_global_position = global_position
	get_parent().remove_child(self)
	_main.add_child(self)
	global_position = _global_position
	$CollisionShape2D.disabled = false
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
