class_name MainGameLoop extends Node2D

@onready var player: Player = $CurrentMap/Node2D/YSort/CharacterBody2D
@onready var curr_room = $CurrentMap/Node2D
@onready var cr_node = get_node("CurrentMap")
@onready var def_mus_path: String = "res://audio/music/coffeeshop.wav"

func _ready():
	SoundManager.play_music(load(def_mus_path),1,"music")
	SoundManager.set_music_volume(.4)

func load_overworld_room(new_room:OWRoom):
	#player.camera.position_smoothing_enabled = false
	player.reparent(self)
	curr_room.queue_free()
	var cr_inst = load(new_room.instance_path).instantiate()
	cr_node.add_child(cr_inst)
	curr_room = cr_inst
	SoundManager.play_music(load(new_room.room_music),1,"music")
	SoundManager.set_music_volume(.4)
	await get_tree().process_frame
	player.reparent(curr_room.get_node("YSort"))
	
	for i in curr_room.get_node("Exits").get_children():
		i.connect("player_entered",load_overworld_room)
	player.position = new_room.player_spawn
	player.camera.global_position = player.global_position
	player.camera.reset_smoothing()
	#player.camera.position_smoothing_enabled = true
