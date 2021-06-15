extends Node

export (Array, NodePath) var spawn_row
export var path_spacing = 45
export var number_of_paths = 5
export (PackedScene) var Path_left
export (PackedScene) var Path_right

export (PackedScene) var Player

enum State { START, PLAYING, NEXT, OVER }

var player
var score = 0
var lives_left = 3
var state
var enemy_left = 0
var half_screen_width 

var enemy_paths_left = []
var enemy_paths_right = []

func _ready():
	randomize()
	half_screen_width = get_viewport().size.x / 2
	
	player = Player.instance()
	player.position = $StartPosition.position
	add_child(player)	

	var left_position = $EnemyPath_Left.position
	var right_position = $EnemyPath_Right.position
	
	for n in number_of_paths:
		var left = Path_left.instance()
		add_child(left)
		left.position = left_position
		left_position += Vector2(path_spacing,0)
		enemy_paths_left.append(left)
		
		var right = Path_right.instance()
		add_child(right)
		right.position = right_position
		right_position -= Vector2(path_spacing,0)
		enemy_paths_right.append(right)
	
	game_start()
	
func game_start():
	state = State.START
	for row in spawn_row:
		enemy_left += get_node(row).spawn_enemy()
		
	$GenericTimer.start(1.0)

func game_over():
	$DiveTimer.stop()
	state = State.OVER
	$HUD.message("Game Over")
	$HUD.show()
	
func next_level():
	game_over()

func enemy_hit(enemy):
	enemy_left -= 1
	score = score + enemy.score
	$HUD.score(score)
	enemy.explode(1)
	
	if enemy_left == 0:
		next_level()
	
func player_hit():
	player.explode(1)
	remove_child(player)
	
	lives_left = lives_left - 1
	$HUD.lives(lives_left)
	
	if lives_left == 0:
		game_over()
	else:
		$GenericTimer.start(2)		
		
func find_closest_path(position):
	var path_found
	var path_array 
	
	if position.x < half_screen_width:
		path_found = enemy_paths_left[0]
		path_array = enemy_paths_left
	else:
		path_found = enemy_paths_right[0]
		path_array = enemy_paths_right
		
	var distance = position.distance_to(path_found.position)
		
	for n in range(1, path_array.size()):
		var check_distance = position.distance_to(path_array[n].position)
		
		if check_distance < distance:
			distance = check_distance
			path_found = path_array[n]
		
	return path_found

func _on_GenericTimer_timeout():
	if state == State.PLAYING:
		add_child(player)
		player.position = $StartPosition.position
	elif state == State.START:
		$HUD.hide()
		$HUD.lives(lives_left)
		state = State.PLAYING
		$DiveTimer.start(5)

func _on_DiveTimer_timeout():
	get_node(spawn_row[0]).dive()
	$DiveTimer.stop()
