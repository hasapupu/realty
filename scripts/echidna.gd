class_name Echidna extends Control

@export var enemy_name := ""
@export var enemy_music_path := ""
@export var hp := 100
@export var atk := 10
@export var custom_responses := {}
@export var music_bpm := 120
@export var input_rate := 4.0
@export var difficulty = 35
@export var player_acts := ["Test Act"]
@export var p_act_dict := {"test act": test}
var bs:BattleSequence
signal spared
signal died

func test():
	print("test")
	bs.switch_panel(["Fight","Skill","Item","Block"])
