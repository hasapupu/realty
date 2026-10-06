class_name HitMarker extends Label

func appear():
	var tween_one = get_tree().create_tween()
	scale = Vector2(.7,.7)
	tween_one.tween_property(self,"scale",Vector2(1,1),.1)
	await tween_one.finished
	await get_tree().create_timer(.3).timeout
	var tween_two = get_tree().create_tween()
	tween_two.set_loops()
	tween_two.tween_property(self,"position",position+Vector2(0,-10),1)
	tween_two.tween_property(self,"scale",scale/2,1)
	tween_two.play()
	await tween_two.loop_finished
	queue_free()

func _ready() -> void:
	appear()
	
