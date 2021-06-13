extends Area2D


export var max_shots = 2
export (PackedScene) var Missile
export (PackedScene) var Explosion

export (NodePath) var flight_path 

var score = 0

var shots_fired = 0
var dive_start_speed = 100
var dive_speed = 200
var return_speed = 100
var dive_start_points
var dive_points
var dive_index = 0
var elapsed = 0
var next_position
var screen_size
var state
var original_position

enum State { IDLE, DIVE_START, DIVING, RETURN }

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	original_position = position
#	dive()
	
func _process(delta):
	var velocity = Vector2.ZERO
	
	if state == State.DIVE_START:
		velocity = (next_position - position).normalized() * dive_start_speed * delta
		position += velocity
		
		if position.distance_to(next_position) < 2.0 :
			dive_index+=1
			
			if dive_index == dive_start_points.size():
				dive_index=0
				next_position = dive_points[dive_index].global_position				
				look_at(next_position)
				rotate(-PI/2)
				state = State.DIVING
			else:
				next_position = dive_start_points[dive_index]
				look_at(next_position)
				rotate(-PI/2)				
	elif state == State.DIVING:		
		if dive_index == dive_points.size():
			velocity = Vector2(0,1) * dive_speed * delta
			position += velocity

			if position.y > screen_size.y:
				position = Vector2(position.x, -10)
				state = State.RETURN
				look_at(original_position)
				rotate(-PI/2)
		else :
			velocity = (next_position - position).normalized() * dive_speed * delta	
			position += velocity
		
			if position.distance_to(next_position) < 2.0 :
				if dive_points[dive_index].fire :
					fire()
				
				dive_index+=1
				
				if dive_index < dive_points.size():
					next_position = dive_points[dive_index].global_position				
					look_at(next_position)
					rotate(-PI/2)
				else:
					look_at(Vector2(position.x,screen_size.y))
					rotate(-PI/2)
	elif state == State.RETURN:
		velocity = (original_position - position).normalized() * return_speed * delta
		position += velocity
		
		if position.distance_to(original_position) < 1 :
			state = State.IDLE
			look_at(Vector2(position.x, position.y+10))
			rotate(1.5 * PI)
			
func dive():
	dive_index = 0
	shots_fired = 0
			
	dive_points = get_node(flight_path).get_children()	

	dive_start_points=[]
	var x_max
	
	if position.x < dive_points[0].global_position.x:
		x_max = max(dive_points[0].global_position.x - position.x,50)
		dive_start_points.push_back(Vector2(position.x + (x_max/2),position.y-20))
		dive_start_points.push_back(Vector2(position.x + x_max,position.y))
	else:
		x_max = max(position.x-dive_points[0].global_position.x,50)
		dive_start_points.push_back(Vector2(position.x - (x_max/2),position.y-20))
		dive_start_points.push_back(Vector2(position.x - x_max,position.y))
	
	state = State.DIVE_START
	look_at(dive_start_points[0])
	rotate(-PI/2)		
	next_position = dive_start_points[0]
	
func fire():
	var missile = Missile.instance()
	missile.position = position
	get_parent().add_child(missile)
	
func explode(explosion_time):
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.position = position
	explosion.explode(explosion_time)
	queue_free()
