extends Node

export (Array, NodePath) var spawn_row
export (Array, NodePath) var enemy_paths_left
export (Array, NodePath) var enemy_paths_right

export (PackedScene) var Player

var player
var score = 0
var lives_left = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.instance()
	player.position = $StartPosition.position
	add_child(player)
	
	game_start()

func game_start():
	for row in spawn_row:
		get_node(row).spawn_enemy()

func game_over():
	print("Game Over")

func enemy_hit(enemy):
	score = score + enemy.score
	print(score)
	enemy.explode(1,5)
	
func player_hit():
	print("Player hit")
	player.explode(1.5)
	remove_child(player)
	
	lives_left = lives_left - 1
	
	if lives_left == 0:
		game_over()
	else:
		$RespawnTimer.start(2)		


func _on_RespawnTimer_timeout():
	add_child(player)
	player.position = $StartPosition.position
