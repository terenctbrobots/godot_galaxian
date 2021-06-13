extends ParallaxBackground


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var sprite_rotation = $ParallaxLayer/Sprite.global_rotation
#	$ParallaxLayer.motion_mirroring = $ParallaxLayer/Sprite.texture.get_size().rotated(sprite_rotation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scroll = Vector2(0,30)
	scroll_offset += scroll * delta
