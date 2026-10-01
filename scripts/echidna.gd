class_name Echidna extends Control

@export var enemy_name := "Test Enemy"
@export var enemy_music_path := "res://audio/music/combative dance.wav"
@export var hp := 100
@export var atk := 10
@export var custom_responses := {}
@export var music_bpm := 120
@export var input_rate := 4.0
@export var difficulty = 35
@export var player_acts := ["Test Act"]
@export var p_act_dict := {"test act": test}
@export var midi_map : MidiData = preload("res://midi/generalbattletheme.mid")
var bs:BattleSequence
signal spared
signal died
var test_points := 0

func test():
	test_points += 1
	if test_points < 3:
		bs.enemy_terminal.queue_write("Test dialogue 1.")
		bs.enemy_terminal.queue_write("Test dialogue 2.")
		bs.switch_panel(["Fight","Skill","Item","Block"])
	else:
		spared.emit()
