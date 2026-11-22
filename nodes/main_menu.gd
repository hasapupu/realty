class_name MainMenu extends CanvasLayer

var max_size = 3
@onready var butts := [$Control/ColorRect/Label,$Control/ColorRect/Label2,$Control/ColorRect/Label3]
@onready var def_strings := []

var curr_butt_i := 0:
	set(value):
		if value >= max_size:
			curr_butt_i = 0
		elif value < 0:
			curr_butt_i = max_size-1
		else:
			curr_butt_i = value
		for i in range(butts.size()):
			butts[i].text = def_strings[i]
		butts[curr_butt_i].text = ">" + butts[curr_butt_i].text
		
func _ready() -> void:
	SoundManager.play_music(load("res://audio/music/sleeping sentinel.wav"))
	if !ResourceLoader.exists("user://" + "everything.tres"):
		(butts[1] as Label).add_theme_color_override("font_color", Color.DIM_GRAY)
		butts.pop_at(1)
		max_size=2
	for i in butts:
		def_strings.append(i.text)
	butts[0].text = ">" + butts[0].text

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		curr_butt_i -= 1
		SoundManager.play_sound(load("res://audio/sfx/menu sfx.wav"))
	elif Input.is_action_just_pressed("ui_down"):
		curr_butt_i += 1
		SoundManager.play_sound(load("res://audio/sfx/menu sfx.wav"))
	if Input.is_action_just_pressed("ui_accept"):
		match curr_butt_i:
			2:
				get_tree().quit()
			0:
				if ResourceLoader.exists("user://" + "everything.tres"):
					var files := DirAccess.open("user://")
					files.list_dir_begin()
					var name := files.get_next()
					while name != "":
						if ResourceLoader.exists("user://" + name):
							print(name)
							DirAccess.remove_absolute("user://" + name)
						name = files.get_next()
					files.list_dir_end()
				get_tree().change_scene_to_file("res://nodes/main.tscn")
			1:
				get_tree().change_scene_to_file("res://nodes/main.tscn")
