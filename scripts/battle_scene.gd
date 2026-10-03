class_name BattleSequence extends Control

var enemy : Echidna
@onready var rhythm_notifier: RhythmNotifier = $RhythmNotifier
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_menu : Control = $NinePatchRect/CenterContainer/GridContainer
@onready var but_path := "res://nodes/menuoption.tscn"
var def_responses:= {"fight":fight,"skill":show_skills,"item":show_inventory,"block":block,"test item":test_item}
var but_list:Array
var selected_i := 0
var inventory : Array
var cursor_init_pos := Vector2(298,155)
var cursor_final_pos := Vector2(25,155)
var cursors := []
var cursor_path := "res://nodes/cursor.tscn"
var difficulty := 30 #0 es 170 kozti szam, minel kisebb, annal nehezebb
var c_active := false:
	set(value):
		if value == false:
			c_tween.stop()
		c_active = value
var c_tween:Tween #c_ stands for cursor always in this script atleast
var input_rate:float = 4.0#in beats
@onready var succes_zone:ColorRect = $Control/ColorRect4
var player_attacking := false
var player_blocking := false
var player_max_hp:int
var player_hp:int:
	set(value):
		if value > player_max_hp:
			player_hp = player_max_hp
		elif value<=0:
			kill_player()
		else:
			#print(value)
			player_hp = value
@onready var fadeout_node:ColorRect = $ColorRect4
@onready var player_hp_bar:Slider = $Control/HSlider
@onready var player_hp_text:Label = $Control/Label3
@onready var hint_terminal:Label = $Control/Label5
var hint_dict:={"fight":"Attack enemy","skill":"Attempt to convince enemy","item":"Open inventory","block":"Block next hit","test item":"Heals 10 hp"}
@onready var enemy_name_label:Label = $Control2/Label
@onready var enemy_health_bar:Slider = $HSlider
@onready var enemy_health_label:Label = $HSlider/Label
@onready var enemy_max_health:int = enemy.hp
@onready var enemy_terminal:EnemyTerminal = $NinePatchRect2
@onready var fadeout_anim:AnimationPlayer = $ColorRect4/AnimationPlayer
signal player_died
var enemy_attack_notes :=[]
var player_notes :=[]
var enemy_fakeout_notes := []
@onready var note_timer : BattleTimer = $Timer
var cursor : Control
var c_tweens := []
var c_index := 0
var button_sfx_path := "res://audio/sfx/menu sfx.wav"

func _ready():
	#fadeout_node.self_modulate.a = 0
	enemy.bs = self
	$EnemyPos.add_child(enemy)
	audio.stream = load(enemy.enemy_music_path)
	rhythm_notifier.bpm = enemy.music_bpm
	#rhythm_notifier.beats(input_rate,true,0).connect(func(start_qte): start_qte())
	#rhythm_notifier.beats(8,true,8).connect(damage_player)
	note_timer.connect("player_note",start_qte)
	switch_panel(["Fight","Skill","Item","Block"])
	input_rate = enemy.input_rate
	difficulty = enemy.difficulty
	succes_zone.size.x = difficulty
	def_responses[enemy.enemy_name.to_lower()] = attack
	hint_dict[enemy.enemy_name.to_lower()] = "Pick target"
	player_hp_bar.max_value = player_max_hp
	player_hp_bar.value = player_hp
	player_hp_text.text = str(player_max_hp) + "/" + str(player_hp)
	enemy_name_label.text = enemy.enemy_name
	enemy_health_bar.max_value = enemy_max_health
	enemy_health_bar.value = enemy.hp
	enemy_terminal.talk_voice_path = enemy.talk_voice_path
	damage_enemy(0)
	extract_notes()
	print(player_notes)
	#print(enemy_fakeout_notes)
	#print(enemy_attack_notes)
	note_timer.bs = self
	note_timer.wait_time = audio.stream.get_length()
	note_timer.start()
	audio.play()
	#enemy_terminal.queue_write("Test dialogue.")
	

func add_butt(b_text:String):
	var b_inst:BattleButt = load(but_path).instantiate()
	b_inst.set_text(b_text)
	but_list.append(b_inst)
	player_menu.add_child(b_inst)

func switch_panel(new_butts:Array):
	if new_butts.is_empty():
		return
	but_list.clear()
	for i in player_menu.get_children():
		i.queue_free()
	for i in new_butts:
		add_butt(i)
	switch_selection(0)

func switch_selection(value:int):
	for i:BattleButt in but_list:
		i.set_selected(false)
	if value < 0:
		selected_i = len(but_list) + value
	elif value > (len(but_list) - 1):
		selected_i = value - len(but_list)
	else:
		selected_i = value
	(but_list[selected_i] as BattleButt).set_selected(true)
	if hint_dict.has((but_list[selected_i] as BattleButt).get_text().to_lower()):
		hint_terminal.text = "* " + hint_dict[(but_list[selected_i] as BattleButt).get_text().to_lower()]
	else:
		hint_terminal.text = ""

func start_qte(duration:float):
	var temp_c = load(cursor_path).instantiate()
	cursors.append(temp_c)
	$Control.add_child(temp_c)
	temp_c.position = cursor_init_pos
	var temp_c_tween : Tween = get_tree().create_tween()
	temp_c_tween.tween_property(temp_c,"position",cursor_final_pos,input_rate)
	temp_c_tween.finished.connect(stop_c_tween)
	c_tweens.append(temp_c_tween)
	
func _process(delta):
	if c_index < cursors.size():
		cursor = cursors[c_index]
		if cursor.visible:
			if Input.is_action_just_pressed("ui_left"):
				c_tweens[c_index].stop()
				cursor.visible = false
				if(cursor.position.distance_to(cursor_final_pos) <= difficulty):
					SoundManager.play_sound(load(button_sfx_path))
					switch_selection(selected_i - 1)
				#print(cursor.position.distance_to(cursor_final_pos))
				c_index += 1
			elif Input.is_action_just_pressed("ui_right"):
				c_tweens[c_index].stop()
				cursor.visible = false
				if(cursor.position.distance_to(cursor_final_pos) <= difficulty):
					SoundManager.play_sound(load(button_sfx_path))
					switch_selection(selected_i + 1)
				#print(cursor.position.distance_to(cursor_final_pos))
				c_index += 1
			elif Input.is_action_just_pressed("ui_accept"):
				c_tweens[c_index].stop()
				cursor.visible = false
				if !player_attacking:
					if(cursor.position.distance_to(cursor_final_pos) <= difficulty):
						if def_responses.has(but_list[selected_i].get_text().to_lower()):
							SoundManager.play_sound(load(button_sfx_path))
							(def_responses[but_list[selected_i].get_text().to_lower()] as Callable).call()
						elif enemy.p_act_dict.has(but_list[selected_i].get_text().to_lower()):
							#print("process")
							SoundManager.play_sound(load(button_sfx_path))
							(enemy.p_act_dict[but_list[selected_i].get_text().to_lower()] as Callable).call()
						c_index += 1
				else:
					player_attacking = false
					damage_enemy(170 - (cursor.position.distance_to(cursor_final_pos)))
					switch_panel(["Fight","Skill","Item","Block"])
					c_index += 1
	
func fight():
	switch_panel([enemy.enemy_name])
	
func attack():
	hint_terminal.text = "* Time your attack!"
	#print("a")
	(but_list[selected_i] as BattleButt).set_selected(false)
	player_attacking = true
	
func block():
	player_blocking = true
	switch_panel(["Fight","Skill","Item","Block"])
	
func damage_player(bullshit:int = 1, amount:int = 100):
	#print(amount)
	if player_blocking:
		player_blocking = false
	else:
		player_hp = player_hp - amount
		player_hp_bar.value = player_hp
		player_hp_text.text = str(player_max_hp) + "/" + str(player_hp)


func show_inventory():
	#print(inventory)
	var names: Array = []
	for i:Item in inventory:
		names.append(i.name.to_lower())
	switch_panel(names)
	
func show_skills():
	switch_panel(enemy.player_acts)
	
func test_item():
	player_hp += 10
	for i:Item in inventory:
		if i.name == "Test Item":
			inventory.erase(i)
			break
	switch_panel(["Fight","Skill","Item","Block"])
	
func damage_enemy(amount:int):
	if enemy.hp - amount > 0:
		enemy.hp -= amount
		enemy_health_bar.value = enemy.hp
		#enemy_health_label.text = str(enemy.hp) + "/" + str(enemy_max_health)
	else:
		enemy.died.emit()

func kill_player():
	#c_tween.stop()
	c_active = false
	audio.stop()
	#await get_tree().create_timer(1)
	fadeout_anim.play("fade_out")
	await  get_tree().process_frame
	await  fadeout_anim.animation_finished
	#print("aaaaaaa")
	await get_tree().create_timer(1).tiemout
	player_died.emit()

func get_note_start_times(midi_data: MidiData, bpm: float) -> Array[Dictionary]:
	var notes: Array[Dictionary] = []

	# Duration of one beat in seconds.
	var seconds_per_beat := 60.0 / bpm

	for track_index in midi_data.tracks.size():
		var track = midi_data.tracks[track_index]
		var time_seconds := track.get_offset_in_seconds()

		for event in track.events:
			# Convert MIDI ticks -> seconds.
			var delta_seconds := (
				float(event.delta_time)
				/ float(midi_data.header.ticks_per_beat)
				* seconds_per_beat
			)

			time_seconds += delta_seconds

			if event is MidiData.NoteOn and event.velocity > 0:
				notes.append({
					"time": time_seconds,
					"note": event.note,
					"velocity": event.velocity,
					"track": track_index
				})

	return notes
	
func extract_notes():
	var temp_notes := get_note_start_times(enemy.midi_map,enemy.music_bpm)
	#print(temp_notes)
	for i in temp_notes:
		if i["note"] == 48:
			player_notes.append(i["time"] - input_rate)
		elif i["note"] == 49:
			enemy_attack_notes.append(i["time"] - input_rate)
		elif i["note"] == 50:
			enemy_fakeout_notes.append(i["time"] - input_rate)

func stop_c_tween():
	cursor.visible = false
	c_index += 1
