class_name SceneContext extends Node2D

@export var local_save: RoomSave
@export var save_name: String

func set_music(path:String):
	SoundManager.play_music(load(path),1)
	
func play_sfx(path:String):
	SoundManager.play_sound(load("path"))
