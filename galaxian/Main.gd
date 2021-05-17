extends Node

export (PackedScene) var Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.instance()
	player.position = $StartPosition.position
	add_child(player)
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
