class_name ShieldPop extends TextureRect

func _ready() -> void:
	scale *= .7
	var tween_uno = get_tree().create_tween()
	tween_uno.tween_property(self, "scale",Vector2(4, 4),.4).set_trans(Tween.TRANS_QUAD)
	await tween_uno.finished
	await get_tree().create_timer(.1).timeout
	queue_free()
