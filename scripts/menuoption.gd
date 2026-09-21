class_name BattleButt extends HBoxContainer

@onready var marker : Label = $Label
@onready var text_node: Label = $Label2

func set_text(value:String):
	$Label2.text = value

func set_selected(value:bool):
	$Label.visible = value
	
func get_text() -> String:
	return $Label2.text
