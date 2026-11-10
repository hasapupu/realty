class_name SceneContext extends Node2D

@export var local_save: RoomSave
@export var save_name: String

func set_music(path:String):
	SoundManager.play_music(load(path),1)
	
func play_sfx(path:String):
	SoundManager.play_sound(load("path"))

func wait(seconds: float):
	await  get_tree().create_timer(seconds).timeout
	
func fade_music(fade_time:float):
	var te = get_tree().create_tween()
	te.tween_method(SoundManager.set_music_volume,SoundManager.get_music_volume(),0,fade_time)
	await te.finished
