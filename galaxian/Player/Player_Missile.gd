extends Area2D

signal enemy_hit(enemy)

export var speed = 400
var _fire = false
var _main 

func _ready():
	_main = get_parent().get_parent()
	print(_main.name) 
	
func fire():
	$CollisionShape2D.disabled = false
	_main.add_child(self)
	connect("enemy_hit",_main,"enemy_hit")
	_fire = true
	
func _process(delta):
	if !_fire :
		return
		
	position  += Vector2(0,-1) * delta * speed

	if global_position.y < 0:
		queue_free()

func _on_Missile_area_entered(area):
	print("Player missile hit "+area.name)
	emit_signal("enemy_hit",area)
