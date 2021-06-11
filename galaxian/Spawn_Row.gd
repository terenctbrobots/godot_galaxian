extends Position2D

export (PackedScene) var EnemySpawn
export var spawn_count = 1
export var spawn_x_spacing = 50
export var enemy_score = 50

func spawn_enemy():
	for n in range(spawn_count):
		var spawn = EnemySpawn.instance()
		spawn.score = enemy_score
		get_parent().add_child(spawn)
		spawn.add_to_group("enemies")
		spawn.position = Vector2(position.x + (n*spawn_x_spacing), position.y)
		
