extends Node

export (PackedScene) var Player

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.instance()
	player.position = $StartPosition.position
	add_child(player)


func enemy_hit(body):
	print(body.name)
	
func player_hit():
	print("Player hit")
