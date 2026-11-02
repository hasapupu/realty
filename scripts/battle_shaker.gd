class_name BattleShaker extends Control

@export var shake_strength := 10.0
@export var shake_duration := 0.2

var original_position: Vector2
var shake_tween: Tween

func _ready() -> void:
	original_position = position

func camera_shake() -> void:
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()

	position = original_position

	shake_tween = create_tween()
	shake_tween.tween_method(
		_shake,
		shake_strength,
		0.0,
		shake_duration
	)

func _shake(strength: float) -> void:
	position = original_position + Vector2(
		randf_range(-strength, strength),
		randf_range(-strength, strength)
	)
