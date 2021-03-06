extends Position2D

export (PackedScene) var EnemySpawn
export var pair_count = 2
export var spawn_x_spacing = 50
export var enemy_score = 50
export var enemy_score_multiplier = 2
export var enemy_speed_multiplier:float = 1.0

enum EnemyType {BLUE, PURPLE, RED, YELLOW }
export (EnemyType) var enemy_type

var attack_row = false

var _enemy_group = []
var _main

func _ready():
	_main = get_node("/root").get_child(0)
	
	if enemy_type == EnemyType.BLUE:
		_main.add_attack_row(self)
		attack_row = true

class SortX:
	static func sort_ascending(a, b):
		if a.position.x < b.position.x:
			return true
		
		return false
		

func spawn_enemy():
	for n in range(0, pair_count):
		var spawn = EnemySpawn.instance()
		spawn.set_score(enemy_score, enemy_score_multiplier)
		spawn.set_speed_multiplier(enemy_speed_multiplier)
		spawn.spawn_row = self
		spawn.set_type(enemy_type)
		get_parent().add_child(spawn)
		_enemy_group.append(spawn)
		spawn.position = Vector2(position.x + spawn_x_spacing/2 + (n*spawn_x_spacing), position.y)

		spawn = EnemySpawn.instance()
		spawn.set_score(enemy_score, enemy_score_multiplier)
		spawn.spawn_row = self
		spawn.set_type(enemy_type)
		_enemy_group.append(spawn)
		get_parent().add_child(spawn)
		spawn.position = Vector2(position.x - spawn_x_spacing/2 - (n*spawn_x_spacing), position.y)		

	_enemy_group.sort_custom(SortX, "sort_ascending")
		
	return pair_count*2
	
func enemy_left():
	return _enemy_group.size()
	
func remove(enemy):
	_enemy_group.erase(enemy)
	
	if  attack_row and _enemy_group.size() == 0:
		_main.remove_attack_row(self)

func find_end_enemy():
	var start = 0
	var end = _enemy_group.size()
	var step = 1

# Randomly choose back to front	
	if randi() % 100 < 50:
		start = _enemy_group.size() - 1
		end = 0
		step = -1
	
	for n in range(start,end,step):
		if _enemy_group[n].can_dive():
			return _enemy_group[n]
			
	return null	
	
func get_wingmen(position, max_count):
	var wingmen = []
	var count = 0
	
	for enemy in _enemy_group:
		if enemy.global_position.distance_to(position) <= 50:
			wingmen.append(enemy)
			count += 1
			
			if max_count == count:
				return wingmen
			
	return wingmen	
		
func dive():
	var enemy = find_end_enemy()
	
	if enemy != null:
		enemy.dive()
		return true
		
	return false
	
func dive_boss(wingmen_row):
	var boss = find_end_enemy()
	
	if boss != null:
		var formation = wingmen_row.get_wingmen(boss.position, 2)
		boss.dive()
		for wingman in formation:
			wingman.dive()
	
