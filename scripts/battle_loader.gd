class_name BattleLoader extends Area2D
@export var enemy_path:String = "res://nodes/testenemy.tscn"
@onready var main:MainGameLoop = get_tree().root.get_node("Node2D")

func _ready() -> void:
	connect("body_entered",start_battle)

func start_battle(body:Player):
	SoundManager.stop_music()
	main.initiate_battle_sequence(load(enemy_path).instantiate())
	queue_free()
