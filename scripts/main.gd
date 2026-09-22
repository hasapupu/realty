class_name MainGameLoop extends Node2D

var player: Player 
@onready var player_pref:PackedScene = preload("res://nodes/player.tscn")
var def_scene_path : String = "res://nodes/cafe.tscn"
var curr_room: SceneContext
@onready var cr_node = get_node("CurrentMap")
@onready var def_mus_path: String = "res://audio/music/coffeeshop.wav"
var save_path := "user://everything.tres"
const battle_scene_path := "res://nodes/battle_scene.tscn"

func _ready():
	if ResourceLoader.exists(save_path) == false:
		print(save_path)
		ResourceSaver.save(MainSave.new(),save_path)
	var savefile:MainSave = ResourceLoader.load(save_path)
	#print(MainSave.new())
	def_scene_path = savefile.scene_path
	def_mus_path = savefile.mus_path
	curr_room = load(def_scene_path).instantiate()
	if curr_room.save_name != "":
		if ResourceLoader.exists("user://" + curr_room.save_name + ".tres"):
			curr_room.local_save = ResourceLoader.load("user://" + curr_room.save_name + ".tres")
	cr_node.add_child(curr_room)
	player=player_pref.instantiate()
	player.inventory = savefile.player_inventory
	curr_room.get_node("YSort").add_child(player)
	player.position = savefile.player_pos
	SoundManager.play_music(load(def_mus_path),1,"music")
	SoundManager.set_music_volume(.4)
	initiate_battle_sequence(load("res://nodes/testenemy.tscn").instantiate())

func load_overworld_room(new_room:OWRoom):
	#player.camera.position_smoothing_enabled = false
	player.reparent(self)
	if curr_room.save_name != "":
		ResourceSaver.save(curr_room.local_save, "user://" + curr_room.save_name + ".tres")
	curr_room.queue_free()
	var cr_inst:SceneContext = load(new_room.instance_path).instantiate()
	if cr_inst.save_name != "":
		if ResourceLoader.exists("user://" + cr_inst.save_name + ".tres"):
			cr_inst.local_save = ResourceLoader.load("user://" + cr_inst.save_name + ".tres")
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
	
func initiate_battle_sequence(enemy:Echidna):
	cr_node.process_mode = Node.PROCESS_MODE_DISABLED
	var bs_inst: BattleSequence = load(battle_scene_path).instantiate()
	bs_inst.enemy = enemy
	bs_inst.player_max_hp = player.max_hp
	bs_inst.player_hp = player.hp
	bs_inst.inventory = player.inventory
	bs_inst.inventory.append(load("res://items/test_item.tres") as Item)
	bs_inst.global_position = player.camera.global_position
	add_child(bs_inst)

func stop_battle_sequence():
	cr_node.process_mode = Node.PROCESS_MODE_ALWAYS
