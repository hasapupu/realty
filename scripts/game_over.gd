class_name GameOver extends Control


@onready var options: ItemList = $ItemList
@onready var labels := [$ItemList/Label,$ItemList/Label2]

func _ready() -> void:
	options.select(0)



func _on_item_list_item_activated(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://nodes/main.tscn")
		1:
			get_tree().quit()


func _on_item_list_item_selected(index: int) -> void:
	for i in labels:
		i.visible = false
	labels[index].visible = true
