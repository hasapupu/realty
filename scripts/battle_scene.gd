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
var cursor_init_pos := Vector2(191,155)
var cursor_final_pos := Vector2(25,155)
@onready var cursor_inst:Control = $Control/Label
var cursor_path := "res://nodes/cursor.tscn"
var difficulty := 30 #0 es 170 kozti szam, minel kisebb, annal nehezebb
var c_active := false:
	set(value):
		if value == false:
			#c_tween.stop()
			pass
		c_active = value
var input_rate:float = 4.0#in beats
@onready var succes_zone:ColorRect = $Control/ColorRect4
var player_attacking := false
var player_blocking := false
var player_max_hp:int
var player_hp:int:
	set(value):
		if value > player_max_hp:
			player_hp = player_max_hp
		elif value<=0 and player_hp > 0:
			kill_player()
			player_hp = value
		else:
			#print(value)
			player_hp = value
@onready var fadeout_node:ColorRect = $ColorRect4
@onready var player_hp_bar:ProgressBar = $Control/HSlider
@onready var player_hp_text:Label = $Control/Label3
@onready var hint_terminal:Label = $Control/Label5
var hint_dict:={"fight":"Attack enemy","skill":"Attempt to convince enemy","item":"Open inventory","block":"Block next hit","test item":"Heals 10 hp"}
@onready var enemy_name_label:Label = $Control2/Label
@onready var enemy_health_bar:ProgressBar = $HSlider
@onready var enemy_health_label:Label = $HSlider/Label
@onready var enemy_max_health:int = enemy.hp
@onready var enemy_terminal:EnemyTerminal = $NinePatchRect2
@onready var fadeout_anim:AnimationPlayer = $ColorRect4/AnimationPlayer
signal player_died
var enemy_attack_notes :=[]
var player_notes :=[]
@onready var note_timer : BattleTimer = $Timer
var button_sfx_path := "res://audio/sfx/menu sfx.wav"
@export var intro_timeout_length := .5
@onready var hit_marker : PackedScene = preload("res://nodes/hit_marker.tscn")
@onready var hit_marker_parent : Control = $HitMarkerParent
@onready var cs : BattleShaker = get_parent()
@onready var shield_marker : TextureRect = $Control2/Label2/TextureRect
var enemy_pos = Vector2(100,30) #magic number bc I hate UI coords
@onready var attack_shields := [$TextureRect,$TextureRect2]
@onready var enemy_attack_vfx_anim : AnimationPlayer = $TextureRect3/vfx_anim
var player_done:= false
var possible_note_positions := []
var note_pos_i := 0

func _ready():
	$TextureRect3.texture = null
	$ColorRect6.visible = false
	$Control2.visible = false
	$HSlider.visible = false
	$Control.visible = false
	$NinePatchRect2.visible = false
	$NinePatchRect.visible = false
	$ColorRect.visible = false
	#fadeout_node.self_modulate.a = 0
	await get_tree().create_timer(intro_timeout_length).timeout
	enemy.bs = self
	$EnemyPos.add_child(enemy)
	SoundManager.play_sound(load("res://audio/sfx/add_sound (1).wav"),"sfx")
	await get_tree().create_timer(intro_timeout_length).timeout
	audio.stream = load(enemy.enemy_music_path)
	rhythm_notifier.bpm = enemy.music_bpm
	#rhythm_notifier.beats(input_rate,true,0).connect(func(start_qte): start_qte())
	#rhythm_notifier.beats(8,true,8).connect(damage_player)
	$ColorRect6.visible = true
	start_qte()
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
	$Control2.visible = true
	SoundManager.play_sound(load("res://audio/sfx/add_sound (1).wav"),"sfx")
	await get_tree().create_timer(intro_timeout_length).timeout
	$HSlider.visible = true
	$Control.visible = true
	SoundManager.play_sound(load("res://audio/sfx/add_sound (1).wav"),"sfx")
	await get_tree().create_timer(intro_timeout_length).timeout
	$NinePatchRect2.visible = true
	$NinePatchRect.visible = true
	SoundManager.play_sound(load("res://audio/sfx/add_sound (1).wav"),"sfx")
	await get_tree().create_timer(intro_timeout_length).timeout
	#damage_enemy(0)
	extract_notes()
	#print(player_notes)
	#print(enemy_fakeout_notes)
	#print(enemy_attack_notes)
	$ColorRect.visible = true
	note_timer.bs = self
	note_timer.wait_time = audio.stream.get_length()
	note_timer.enemy_attack.connect(new_bar)
	note_timer.player_note.connect(on_note)
	start_bar()
	note_timer.start()
	enemy_terminal.queue_write("* (" + enemy.enemy_name + [" showed up!", " appeared!"," attacks!" ].pick_random() + ")")
	switch_panel(["Fight","Skill","Item","Block"])
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

func start_qte():
	cursor_inst.position = cursor_init_pos

	
func _process(delta):
	if player_done == false:
		if Input.is_action_just_pressed("ui_left"):
			player_done = true
			SoundManager.play_sound(load(button_sfx_path))
			switch_selection(selected_i - 1)
			spawn_hit_marker(but_list[selected_i].get_text(),cursor_inst.position)
			#print(cursor.position.distance_to(cursor_final_pos))
		elif Input.is_action_just_pressed("ui_right"):
			player_done = true
			SoundManager.play_sound(load(button_sfx_path))
			switch_selection(selected_i + 1)
			spawn_hit_marker(but_list[selected_i].get_text(), cursor_inst.position)
		elif Input.is_action_just_pressed("ui_accept"):
			player_done = true
			if !player_attacking:
				spawn_hit_marker(but_list[selected_i].get_text(), cursor_inst.position)
				if def_responses.has(but_list[selected_i].get_text().to_lower()):
					SoundManager.play_sound(load(button_sfx_path))
					(def_responses[but_list[selected_i].get_text().to_lower()] as Callable).call()
				elif enemy.p_act_dict.has(but_list[selected_i].get_text().to_lower()):
						#print("process")
					SoundManager.play_sound(load(button_sfx_path))
					(enemy.p_act_dict[but_list[selected_i].get_text().to_lower()] as Callable).call()
			else:
				player_attacking = false
				damage_enemy(170)
				spawn_hit_marker(str(int(170)), enemy_pos) #HARDCODED MAGIC NUMBERS YAAAAAYYYYY
				switch_panel(["Fight","Skill","Item","Block"])


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
	#print("amount")
	SoundManager.play_sound(load("res://audio/sfx/player_hit.wav"))
	cs.camera_shake()
	if player_blocking:
		player_blocking = false
		show_shield_icon(player_blocking)
		return
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
	SoundManager.play_sound(load("res://audio/sfx/player_attack.wav"))
	if enemy.hp - amount > 0:
		enemy.hp -= amount
		enemy_health_bar.value = enemy.hp
		play_attack_anim()
		#enemy_health_label.text = str(enemy.hp) + "/" + str(enemy_max_health)
	else:
		enemy.died.emit()

func kill_player():
	#c_tween.stop()
	c_active = false
	audio.stop()
	note_timer.paused = true

	#await get_tree().create_timer(1)
	fadeout_anim.play("fade_out")
	await  get_tree().process_frame
	await  fadeout_anim.animation_finished
	#print("aaaaaaa")
	await get_tree().create_timer(1).timeout
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
		#print(i["note"])
		if i["note"] == 98:
			player_notes.append(i["time"] - input_rate)
		elif i["note"] == 100 :
			enemy_attack_notes.append(i["time"] - input_rate)
	
func spawn_hit_marker(label_text:String, m_pos: Vector2 = Vector2.ZERO):
	var temp_marker : HitMarker = hit_marker.instantiate()
	temp_marker.text = label_text
	temp_marker.position = m_pos + Vector2(0, -10)
	$Control.add_child(temp_marker)

func show_shield_icon(shield_up:bool):
	var sh_path = "res://nodes/shield_down.tscn"
	if shield_up:
		sh_path = "res://nodes/shield_up.tscn"
	var temp_icon: TextureRect = load(sh_path).instantiate()
	add_child(temp_icon)
	
func play_attack_blink():
	var blink_tween : Tween = get_tree().create_tween()

	blink_tween.tween_property((enemy.get_node("TextureRect") as TextureRect).material, "shader_parameter/time",1,1.0)
	await blink_tween.finished
	((enemy.get_node("Sprite2D") as TextureRect).material as ShaderMaterial).set_shader_parameter("time",0.0)


func play_attack_anim():
	var a_shields_def_pos := []
	for i:NinePatchRect in attack_shields:
		i.position.y = $EnemyPos.position.y
		a_shields_def_pos.append(Vector2(i.position.x,i.position.y))
	var as_tween = get_tree().create_tween()
	as_tween.set_loops(1)
	as_tween.set_parallel(true)
	for i:NinePatchRect in attack_shields:
		as_tween.tween_property(i,"position",$EnemyPos.position - Vector2(i.pivot_offset.x,0),.2)
	as_tween.play()
	await as_tween.finished
	#print("fin")
	play_attack_blink()
	#print(((enemy.get_node("Sprite2D") as TextureRect).material as ShaderMaterial).get_shader_parameter("time"))
	await get_tree().create_timer(.05).timeout
	for i in range(attack_shields.size()):
		attack_shields[i].position = a_shields_def_pos[i]
		
func new_bar():
	player_done = false
	for i in range(difficulty):
		await get_tree().process_frame
	if !player_blocking:
		damage_player(1,1)
	else:
		show_shield_icon(true)
		player_blocking = false
	start_bar()

func start_bar():
	possible_note_positions.clear()
	var i = note_timer.player_index
	var div_c := 1
	while (
		i < player_notes.size()
		and note_timer.e_attack_index < enemy_attack_notes.size()
		and player_notes[i] < enemy_attack_notes[note_timer.e_attack_index]
	):
		div_c += 1
		i += 1
	for j in range(div_c):
		var progress := float(j) / float(div_c)
		possible_note_positions.append(
		cursor_init_pos.lerp(cursor_final_pos, progress)
		)
	note_pos_i = 0
	cursor_inst.position = possible_note_positions[note_pos_i]
	
func on_note():
	note_pos_i += 1
	cursor_inst.position = possible_note_positions[note_pos_i]
	print(cursor_inst.position)
	player_done = false
	player_blocking = false
