class_name Exit extends Area2D
signal player_entered(room:OWRoom)

@export var target_room: OWRoom

func _on_body_entered(body: Player) -> void:
	emit_signal("player_entered",target_room)
