extends Node

export (Array, NodePath) var spawn_row
export var path_spacing = 45
export var number_of_paths = 5
export (PackedScene) var Path_left
export (PackedScene) var Path_right

export (PackedScene) var player

enum State { START, PLAYING, RESPAWN, NEXT, OVER }
enum AttackPhase { REGULAR, BOSS, AGRESSIVE }

var _player
var _score = 0
var _lives_left = 3
var _state
var _enemy_left = 0
var _half_screen_width 
var _enemy_diving = 0
var _dive_timer = 5

var _enemy_paths_left = []
var _enemy_paths_right = []

var _attack_rows = []

func _ready():
	randomize()
	_half_screen_width = get_viewport().size.x / 2
	
	_player = player.instance()
	spawn_player()

	var left_position = $EnemyPath_Left.position
	var right_position = $EnemyPath_Right.position
	
	for n in number_of_paths:
		var left = Path_left.instance()
		add_child(left)
		left.position = left_position
		left_position += Vector2(path_spacing,0)
		_enemy_paths_left.append(left)
		
		var right = Path_right.instance()
		add_child(right)
		right.position = right_position
		right_position -= Vector2(path_spacing,0)
		_enemy_paths_right.append(right)
	
	game_start()
	
func game_start():
	_state = State.START
	for row in spawn_row:
		_enemy_left += get_node(row).spawn_enemy()
		
	_attack_rows.append(get_node(spawn_row[0]))
	_attack_rows.append(get_node(spawn_row[1]))
	_attack_rows.append(get_node(spawn_row[2]))
		
	$GenericTimer.start(1.0)
	
func remove_attack_row(row):
	if _attack_rows.has(row):
		_attack_rows.erase(row)

func game_over():
	$DiveTimer.stop()
	_state = State.OVER
	$HUD.message("Game Over")
	$HUD.show()
	
func next_level():
	game_over()

func enemy_hit(enemy):
			
	_enemy_left -= 1
	_score += enemy.score
	$HUD.score(_score)
	enemy.explode(1)
	
	if _enemy_left == 0:
		next_level()
	
func player_hit(enemy):
	
	# Don't let anybody else dive until player respanws
	if _enemy_diving > 0:
		$DiveTimer.stop()	
		
	_state = State.RESPAWN
	
	_player.explode(1)
	remove_child(_player)
	
	_lives_left -= 1
	$HUD.lives(_lives_left)
	
	if _lives_left == 0:
		game_over()
	elif _enemy_diving == 0:
		$GenericTimer.start(2)

	if enemy.is_enemy():
		enemy_hit(enemy)
		
func spawn_player():
		add_child(_player)
		_player.position = $StartPosition.position	
		
func dive_start():
	_enemy_diving += 1
		
func dive_end():
	_enemy_diving -= 1
	
	if _enemy_diving == 0 and _state == State.RESPAWN:
		spawn_player()
		_state = State.PLAYING
		$DiveTimer.start(_dive_timer)
		
func find_closest_path(position):
	var path_found
	var path_array 
	
	if position.x < _half_screen_width:
		path_found = _enemy_paths_left[0]
		path_array = _enemy_paths_left
	else:
		path_found = _enemy_paths_right[0]
		path_array = _enemy_paths_right
		
	var distance = position.distance_to(path_found.position)
		
	for n in range(1, path_array.size()):
		var check_distance = position.distance_to(path_array[n].position)
		
		if check_distance < distance:
			distance = check_distance
			path_found = path_array[n]
		
	return path_found

func _on_GenericTimer_timeout():
	if _state == State.PLAYING:
		spawn_player()
	elif _state == State.START:
		$HUD.hide()
		$HUD.lives(_lives_left)
		_state = State.PLAYING
		$DiveTimer.start(_dive_timer)

func _on_DiveTimer_timeout():			
	if _attack_rows.size() > 0:
		var random_row = randi() % _attack_rows.size() 
		_attack_rows[random_row].dive()
