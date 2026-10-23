class_name Echidna extends Control

@export var enemy_name := "Test Enemy"
@export var enemy_music_path := "res://audio/music/combative dance.wav"
@export var hp := 1000
@export var atk := 10
@export var custom_responses := {}
@export var music_bpm := 120
@export var input_rate := 4.0
@export var difficulty = 35
@export var player_acts := ["Test Act"]
@export var p_act_dict := {"test act": test}
@export var midi_map : MidiData = preload("res://midi/midi_basic_enemy_map.mid")
@export var talk_voice_path:= "res://audio/sfx/def_talkvoice.wav"
var bs:BattleSequence
signal spared
signal died
var test_points := 0
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func test():
	test_points += 1
	if test_points < 3:
		bs.enemy_terminal.queue_write("Test dialogue 1.")
		bs.enemy_terminal.queue_write("Test dialogue 2.")
		bs.switch_panel(["Fight","Skill","Item","Block"])
	else:
		spared.emit()
		
func windup():
	anim_player.play("windup")
	#bs.damage_player(0, 10)

func attack():
	anim_player.play("attack")
	await anim_player.animation_finished
	bs.enemy_attack_vfx_anim.play("attack_1")
	await bs.enemy_attack_vfx_anim.animation_finished
	bs.damage_player(0, 10)
