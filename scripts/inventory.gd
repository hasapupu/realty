extends Control


func _on_item_list_item_selected(index: int) -> void:
	SoundManager.play_sound(load("res://audio/sfx/menu sfx.wav"))
