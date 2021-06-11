extends Node2D

func explode(explosion_time):
	$Timer.start(explosion_time)

func _on_Timer_timeout():
	queue_free()
