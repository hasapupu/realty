class_name BattleSequence extends Control

var enemy : Echidna
@onready var rhythm_notifier: RhythmNotifier = $RhythmNotifier
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var player_menu : Control = $NinePatchRect/CenterContainer/GridContainer
@onready var but_path := "res://nodes/menuoption.tscn"
var def_responses:= {"fight":null,"skill":null,"item":null,"block":null}
var but_list:Array
var selected_i := 0
var inventory : Array
var cursor_init_pos := Vector2(298,158)
var cursor_final_pos := Vector2(25,158)
@onready var cursor := $Control/Label
var difficulty := 30 #0 es 170 kozti szam, minel kisebb, annal nehezebb
var c_active := false:
	set(value):
		if value == false:
			c_tween.stop()
		c_active = value
var c_tween:Tween #c_ stands for cursor always in this script atleast
var input_rate:float = 4.0#in beats
@onready var succes_zone:ColorRect = $Control/ColorRect4

func _ready():
	$EnemyPos.add_child(enemy)
	audio.stream = load(enemy.enemy_music_path)
	rhythm_notifier.bpm = enemy.music_bpm
	rhythm_notifier.beats(input_rate,true,0).connect(func(start_qte): start_qte())
	switch_panel(["Fight","Skill","Item","Block"])
	input_rate = enemy.input_rate
	difficulty = enemy.difficulty
	succes_zone.size.x = difficulty
	audio.play()
	

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

func start_qte():
	if c_tween:
		c_tween.stop()
	cursor.position = cursor_init_pos
	c_tween = get_tree().create_tween()
	c_tween.tween_property(cursor,"position",cursor_final_pos,rhythm_notifier.beat_length * input_rate)
	c_active = true
	
func _process(delta):
	if c_active:
		if Input.is_action_just_pressed("ui_left"):
			c_active = false
			if(cursor.position.distance_to(cursor_final_pos) <= difficulty):
				switch_selection(selected_i - 1)
			#print(cursor.position.distance_to(cursor_final_pos))
			
		elif Input.is_action_just_pressed("ui_right"):
			c_active = false
			if(cursor.position.distance_to(cursor_final_pos) <= difficulty):
				switch_selection(selected_i + 1)
			#print(cursor.position.distance_to(cursor_final_pos))
