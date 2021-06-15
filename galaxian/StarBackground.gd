extends ParallaxBackground

func _process(delta):
	var scroll = Vector2(0,30)
	scroll_offset += scroll * delta
