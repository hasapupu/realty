
extends Node2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Sprite2D = $Sprite2D2

func _ready() -> void:
	var margins = sprite.position
	var s_margins = shadow.scale
	var s_tween: Tween = get_tree().create_tween()
	var float_tween: Tween = get_tree().create_tween()
	float_tween.set_loops()
	s_tween.set_loops()
	float_tween.set_trans(Tween.TRANS_SINE)
	s_tween.set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(sprite,"position",margins + Vector2(0,-10), 2)
	s_tween.tween_property(shadow, "scale",s_margins * 1.5, 2)
	float_tween.tween_property(sprite,"position",margins + Vector2(0,10), 2)
	s_tween.tween_property(shadow, "scale",s_margins * 0.75, 2)
