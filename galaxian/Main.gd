extends Node

export (Array, NodePath) var spawn_row
export (Array, NodePath) var enemy_paths_left
export (Array, NodePath) var enemy_paths_right

export (PackedScene) var Player

enum State { START, PLAYING, OVER }


var player
var score = 0
var lives_left = 3
var state

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.instance()
	player.position = $StartPosition.position
	add_child(player)
	
	game_start()

func game_start():
	state = State.START
	for row in spawn_row:
		get_node(row).spawn_enemy()
		
	$GenericTimer.start(1.0)

func game_over():
	state = State.OVER
	$HUD.message("Game Over")
	$HUD.show()

func enemy_hit(enemy):
	score = score + enemy.score
	$HUD.score(score)
	enemy.explode(1.5)
	
func player_hit():
	player.explode(1.5)
	remove_child(player)
	
	lives_left = lives_left - 1
	$HUD.lives(lives_left)
	
	if lives_left == 0:
		game_over()
	else:
		$GenericTimer.start(2)		


func _on_GenericTimer_timeout():
	if state == State.PLAYING:
		add_child(player)
		player.position = $StartPosition.position
	elif state == State.START:
		$HUD.hide()
		$HUD.lives(lives_left)
		state = State.PLAYING
