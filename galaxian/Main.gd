extends Node

export (Array, NodePath) var spawn_row
export var path_spacing = 45
export var number_of_paths = 5
export (PackedScene) var Path_left
export (PackedScene) var Path_right

export (PackedScene) var player

enum State { START, PLAYING, RESPAWN, NEXT, OVER, ATTRACT }
enum AttackPhase { START, MID, END }

var _player
var _score = 0
var _lives_left = 3
var _state
var _enemy_left = 0
var _enemy_total

var _half_screen_width 
var _enemy_diving = 0
var _dive_timer = 5

var _enemy_paths_left = []
var _enemy_paths_right = []

var _attack_rows = []
var _phase
var _game_data

var _current_stage_data
var _current_stage = 0

var StageData 


func _ready():
	StageData = preload("res://StageData.gd")
	
	randomize()
	_half_screen_width = get_viewport().size.x / 2
	
	var file = File.new()
	file.open("res://game_data.json", File.READ)
	
	var content = file.get_as_text()
	file.close()
	
	var json_data = JSON.parse(content)
	
	if json_data.error != 0:
		print("JSON Parse error")
	else:	
		_game_data = json_data.result
	
	_current_stage_data = StageData.new(_game_data["0"])
	
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
	set_attack_phase(AttackPhase.START)
	_enemy_total = 0
	
	for row in spawn_row:
		_enemy_left += get_node(row).spawn_enemy()

	_enemy_total = _enemy_left
		
	$GenericTimer.start(1.0)
	
func add_attack_row(row):
	_attack_rows.append(row)
	
func remove_attack_row(row):
	_attack_rows.erase(row)

func game_over():
	$DiveTimer.stop()
	_state = State.OVER
	$HUD.message("Game Over")
	$HUD.show()
	
func next_stage():
	_state = State.NEXT
	remove_child(_player)
	$HUD.message("Next Stage")
	_current_stage += 1
	
	if _game_data.has(str(_current_stage_data)):
		_current_stage_data = StageData.new(_game_data[str(_current_stage)])
		
	$GenericTimer.start()
	
func set_attack_phase(new_phase):
	match new_phase:
		AttackPhase.START:
			_dive_timer = _current_stage_data.dive_timer_start
		AttackPhase.MID:
			_dive_timer = _current_stage_data.dive_timer_mid 
		AttackPhase.END:
			_dive_timer = _current_stage_data.dive_timer_end
			
	_phase = new_phase

func enemy_hit(enemy):
			
	_enemy_left -= 1

	_score += enemy.get_score()
	$HUD.score(_score)
	enemy.explode(1)
	
	if _enemy_left == 0:
		next_stage()
	else:
		var enemy_percent = float(_enemy_left) / _enemy_total		
		
		if _phase == AttackPhase.START and enemy_percent <= _current_stage_data.attack_phase_mid:
				set_attack_phase(AttackPhase.MID)
		if _phase == AttackPhase.MID and enemy_percent <= _current_stage_data.attack_phase_end:
				set_attack_phase(AttackPhase.END) 
	
func player_hit(enemy):
	
	# Don't let anybody else dive until player respanws
	$DiveTimer.stop()	
		
	_state = State.RESPAWN
	
	_player.explode(1)
	remove_child(_player)
	
	_lives_left -= 1
	$HUD.lives(_lives_left)
	
	if _lives_left == 0:
		game_over()

	if enemy.is_enemy():
		enemy_hit(enemy)
		
func spawn_player():
		add_child(_player)
		_player.position = $StartPosition.position	
		_player.activate()
		
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
	
func random_dive(row_count):
	var random_row = randi() % row_count
	
	for row in range(random_row, 0 , -1): 
		if _attack_rows[row].dive():
			break
	

func _on_GenericTimer_timeout():
	if _state == State.PLAYING:
		spawn_player()
	elif _state == State.START:
		$HUD.hide()
		$HUD.lives(_lives_left)
		_state = State.PLAYING
		$DiveTimer.start(_dive_timer)
	elif _state == State.NEXT:
		$HUD.hide()
		game_start()
		spawn_player()
		

func _on_DiveTimer_timeout():
	match _phase:
		AttackPhase.START:
			random_dive(3)
		AttackPhase.MID:
			var random_boss = randi() % 2
			
			if random_boss == 0:
				get_node(spawn_row[5]).dive_boss(get_node(spawn_row[4]))
			else:
				random_dive(4)
		AttackPhase.END:
			var random_boss = randi() % 2

			if random_boss == 0:
				get_node(spawn_row[5]).dive_boss(get_node(spawn_row[4]))
			else:
				random_dive(5)
