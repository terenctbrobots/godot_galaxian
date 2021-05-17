extends Area2D

export (PackedScene) var Missile
export var speed = 400
var screen_size
var missile = null
var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	screen_size = get_viewport_rect().size
	$MissileTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		
	if Input.is_action_pressed("ui_accept") and missile:
		missile.fire()
		missile = null
		$MissileTimer.start()
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)

func _on_MissileTimer_timeout():
	if missile:
		return
		
	missile = Missile.instance()

	if (parent):
		parent.add_child(missile)
	else:
		add_child(missile)
	
	missile.position = $MissilePosition.position
#	missile.fire()
	
	
