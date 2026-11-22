class_name MainMenu extends CanvasLayer

@onready var butts := [$Control/ColorRect/Label,$Control/ColorRect/Label2,$Control/ColorRect/Label3]
var curr_butt_i := 0:
	set(value):
		if value >= 3:
			curr_butt_i = 0
		elif value < 0:
			curr_butt_i = 2
		else:
			curr_butt_i = value

func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		curr_butt_i -= 1
	elif Input.is_action_pressed("ui_down"):
		curr_butt_i += 1
	for i : Label in butts:
		i.text.replace(">","")
	butts[curr_butt_i].text = ">" + butts[curr_butt_i].text 
	if Input.is_action_just_pressed("ui_accept"):
		match curr_butt_i:
			2:
				get_tree().quit()
			0:
				if ResourceLoader.exists("user://" + "everything.tres"):
					DirAccess.remove_absolute("user://" + "everything.tres")
				get_tree().change_scene_to_file("res://nodes/main.tscn")
			1:
				get_tree().change_scene_to_file("res://nodes/main.tscn")
