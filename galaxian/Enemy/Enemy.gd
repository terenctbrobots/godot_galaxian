extends Area2D


export var max_shots = 2
export (PackedScene) var Missile
export (PackedScene) var Explosion

signal dive_start
signal dive_end

var spawn_row

var _shots_fired = 0
var _dive_start_speed = 100
var _dive_speed = 200
var _return_speed = 100
var _dive_start_points
var _dive_points
var _dive_index = 0
var _elapsed = 0
var _next_position
var _screen_size
var _state
var _original_position
var _main

var _score
var _score_multiplier = 2

enum EnemyType {BLUE, PURPLE, RED, YELLOW }
enum State { IDLE, DIVE_START, DIVING, RETURN }

func _ready():
	_main = get_node("/root").get_child(0)
	assert(connect("dive_start",_main,"dive_start") == 0)
	assert(connect("dive_end",_main,"dive_end") == 0)	
	_screen_size = get_viewport().size
	_state = State.IDLE
#	dive()
	
func _process(delta):
	var velocity = Vector2.ZERO
	
	if _state == State.DIVE_START:
		velocity = (_next_position - position).normalized() * _dive_start_speed * delta
		position += velocity
		
		if position.distance_to(_next_position) < 2.0 :
			_dive_index+=1
			
			if _dive_index == _dive_start_points.size():
				_dive_index=0
				_next_position = _dive_points[_dive_index].global_position				
				look_at(_next_position)
				rotate(-PI/2)
				_state = State.DIVING
			else:
				_next_position = _dive_start_points[_dive_index]
				look_at(_next_position)
				rotate(-PI/2)				
	elif _state == State.DIVING:		
		if _dive_index == _dive_points.size():
			velocity = Vector2(0,1) * _dive_speed * delta
			position += velocity

			if position.y > _screen_size.y:
				position = Vector2(position.x, -10)
				_state = State.RETURN
				look_at(_original_position)
				rotate(-PI/2)
		else :
			velocity = (_next_position - position).normalized() * _dive_speed * delta	
			position += velocity
		
			if position.distance_to(_next_position) < 2.0 :
				if _dive_points[_dive_index].fire :
					fire()
				
				_dive_index+=1
				
				if _dive_index < _dive_points.size():
					_next_position = _dive_points[_dive_index].global_position				
					look_at(_next_position)
					rotate(-PI/2)
				else:
					look_at(Vector2(position.x,_screen_size.y))
					rotate(-PI/2)
	elif _state == State.RETURN:
		velocity = (_original_position - position).normalized() * _return_speed * delta
		position += velocity
		
		if position.distance_to(_original_position) < 1 :
			_state = State.IDLE
			emit_signal("dive_end")
			z_index = 0
			look_at(Vector2(position.x, position.y+10))
			rotate(1.5 * PI)
			
func set_type(enemy_type):
	if enemy_type == EnemyType.BLUE:
		$AnimatedSprite.animation = "blue"
	elif enemy_type == EnemyType.PURPLE:
		$AnimatedSprite.animation = "purple"
	elif enemy_type == EnemyType.RED :
		$AnimatedSprite.animation = "red"
	else :
		$AnimatedSprite.animation = "yellow"
		
func set_score(score, multiplier):
	_score = score
	_score_multiplier = multiplier
	
func get_score():
	if _state != State.IDLE:
		return _score * _score_multiplier
		
	return _score
	
func set_speed_multiplier(multiplier):
	_dive_speed *= multiplier
	_return_speed *= multiplier
	_dive_start_speed *= multiplier
		
func is_enemy():
	return true
			
func can_dive():
	return _state == State.IDLE
				
func dive():
	var flight_path = _main.find_closest_path(position)
	
	emit_signal("dive_start")
	_original_position = position
	z_index = 1
	_dive_index = 0
	_shots_fired = 0
			
	_dive_points = flight_path.get_children()	

	_dive_start_points=[]
	var x_max
	
	if position.x < _dive_points[0].global_position.x:
		x_max = max(_dive_points[0].global_position.x - position.x,50)
		_dive_start_points.push_back(Vector2(position.x + (x_max/2),position.y-20))
		_dive_start_points.push_back(Vector2(position.x + x_max,position.y))
	else:
		x_max = max(position.x-_dive_points[0].global_position.x,50)
		_dive_start_points.push_back(Vector2(position.x - (x_max/2),position.y-20))
		_dive_start_points.push_back(Vector2(position.x - x_max,position.y))
	
	_state = State.DIVE_START
	look_at(_dive_start_points[0])
	rotate(-PI/2)		
	_next_position = _dive_start_points[0]
	
func fire():
	var missile = Missile.instance()
	missile.position = position
	_main.add_child(missile)
	$AudioFire.play()
	
func explode(explosion_time):
	spawn_row.remove(self)
	if _state != State.IDLE:
		emit_signal("dive_end")
	
	var explosion = Explosion.instance()
	_main.add_child(explosion)
	explosion.position = position
	explosion.explode(explosion_time)
	queue_free()
