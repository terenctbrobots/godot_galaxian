extends Position2D

export (PackedScene) var EnemySpawn
export var pair_count = 2
export var spawn_x_spacing = 50
export var enemy_score = 50
export var group_id = "enemies"
enum EnemyType {BLUE, PURPLE, RED, YELLOW }
export (EnemyType) var enemy_type

class SortX:
	static func sort_ascending(a, b):
		if a.position.x < b.position.x:
			return true
		
		return false

func spawn_enemy():
	for n in range(0, pair_count):
		var spawn = EnemySpawn.instance()
		spawn.score = enemy_score
		spawn.set_type(enemy_type)
		get_parent().add_child(spawn)
		spawn.add_to_group(group_id)
		spawn.position = Vector2(position.x + spawn_x_spacing/2 + (n*spawn_x_spacing), position.y)

		spawn = EnemySpawn.instance()
		spawn.score = enemy_score
		spawn.set_type(enemy_type)
		get_parent().add_child(spawn)
		spawn.add_to_group(group_id)
		spawn.position = Vector2(position.x - spawn_x_spacing/2 - (n*spawn_x_spacing), position.y)
		
	return pair_count*2
		
func dive():
	var enemy_group = get_tree().get_nodes_in_group(group_id)
	enemy_group.sort_custom(SortX, "sort_ascending")

	var start = 0
	var end = enemy_group.size()
	var step = 1

# Randomly choose back to front	
	if randi() % 100 < 50:
		start = enemy_group.size() - 1
		end = 0
		step = -1
	
	for n in range(start,end,step):
		if enemy_group[n].can_dive():
			var enemy = enemy_group[n]	
			var flight_path = get_parent().find_closest_path(enemy.position)
			enemy.dive(flight_path)
			return true
		
	return false
	
	
