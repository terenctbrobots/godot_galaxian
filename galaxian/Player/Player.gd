extends Area2D

export (PackedScene) var Missile
export (PackedScene) var Explosion

export var speed = 400

signal player_hit

var screen_size
var missile = null

func explode(explosion_timer):
	var explosion = Explosion.instance()
	get_parent().add_child(explosion)
	explosion.position = position
	explosion.explode(explosion_timer)

func _ready():
	connect("player_hit",get_parent(),"player_hit")	
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

	add_child(missile)
	
	missile.position = $MissilePosition.position
#	missile.fire()
	
func _on_Player_area_entered(area):
	emit_signal("player_hit")
