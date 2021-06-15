extends Position2D

export (PackedScene) var EnemySpawn
export var pair_count = 2
export var spawn_x_spacing = 50
export var enemy_score = 50
export var group_id = "enemies"
enum EnemyType {BLUE, PURPLE, RED, YELLOW }
export (EnemyType) var enemy_type

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
	var enemy = enemy_group[0]
	
	var flight_path = get_parent().find_closest_path(enemy.position)
	
	enemy.dive(flight_path)
	
	