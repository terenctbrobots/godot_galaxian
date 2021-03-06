extends Area2D

export (PackedScene) var Missile
export (PackedScene) var Explosion

export var speed = 350

var _can_move = false

signal player_hit(enemy)

var _screen_size
var _missile = null
var _main

func explode(explosion_timer):
	_can_move = false
	$CollisionShape2D.set_deferred("disabled",true)
	var explosion = Explosion.instance()
	_main.add_child(explosion)
	explosion.position = position
	explosion.explode(explosion_timer)
	
func activate():
	_can_move = true
	$CollisionShape2D.disabled = false

func _ready():
	_main = get_node("/root").get_child(0)
	assert(connect("player_hit",_main,"player_hit") == 0)
	_screen_size = get_viewport_rect().size
	$MissileTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _can_move == false:
		return
		
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		
	if Input.is_action_pressed("ui_accept") and _missile:
		_missile.fire()
		$AudioFire.play()
		_missile = null
		$MissileTimer.start()
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, _screen_size.x)

func _on_MissileTimer_timeout():
	if _missile:
		return
		
	_missile = Missile.instance()

	add_child(_missile)
	
	_missile.position = $MissilePosition.position
#	_missile.fire()
	
func _on_Player_area_entered(area):
	emit_signal("player_hit",area)
