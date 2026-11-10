class_name CafeContext extends SceneContext

@onready var overlay : TileMapLayer = $YSort/TileMapLayer4
@onready var poster_npc = $NPCs/Intractable4
@onready var loverboy = $YSort/Sprite2D13
var player:Player 
@onready var loverboy_npx = $NPCs/Intractable6
@onready var barista_npc = $YSort/Sprite2D/Intractable
@onready var love_particles = $Background/CPUParticles2D
@onready var barrier = $NPCs/Intractable18
@onready var nav_unc = $YSort/CharacterBody2D2
@onready var unc = $YSort/Sprite2D5
@onready var eyelid_overlay: ColorRect = $Background/CanvasLayer/ColorRect
@onready var line_npcs := [$YSort/Sprite2D6, $YSort/Sprite2D7, $YSort/Sprite2D8]
var tw:Tween
var te:Tween
var curr_sound := 1.0

func _ready():
	if local_save.flags.has("poster") and local_save.flags["poster"]:
		hide_poster()
	if local_save.flags.has("obstacle"):
		barrier.queue_free()
		loverboy_npx.queue_free()
		loverboy.position = Vector2(215,84)
		loverboy.get_node("AnimationPlayer").play("look_up")
		barista_npc.dialogue_path = "res://dialogues/cafe_confession.dialogue"
		love_particles.visible = true
	await get_tree().process_frame
	player = $YSort/CharacterBody2D

func hide_poster():
	overlay.visible = true
	poster_npc.queue_free()
	local_save.flags["poster"] = true
	
func move_lover(x,y):
	local_save.flags["obstacle"] = true
	loverboy_npx.queue_free()
	loverboy.get_node("AnimationPlayer").play("walk_right")
	loverboy.nav_to(x,y)
	await loverboy.path_done
	loverboy.get_node("AnimationPlayer").play("look_up")
	barista_npc.dialogue_path = "res://dialogues/cafe_confession.dialogue"
	love_particles.visible = true
	barrier.queue_free()

func move_player(x,y):
	player.in_cuts = true
	player.anim.play("walk_up")
	await get_tree().create_timer(1)
	await player.nav_to(x,y)
	player.anim.play("idle_down")
	player.in_cuts = false

func switch_uncs():
	SoundManager.play_ambient_sound(load("res://audio/sfx/enemy_encounter.wav"))
	unc.visible = false
	unc.process_mode = Node.PROCESS_MODE_DISABLED
	nav_unc.visible = true
	nav_unc.process_mode = Node.PROCESS_MODE_ALWAYS

func move_unc():
	nav_unc.get_node("AnimationPlayer").play("walk_up")
	nav_unc.nav_to(0,-50)
	await nav_unc.path_done
	nav_unc.get_node("AnimationPlayer").play("look_up")
	await get_tree().create_timer(.5).timeout
	SoundManager.play_sound(load("res://audio/sfx/door_open.wav"))
	nav_unc.queue_free()

func close_eyelids():
	curr_sound = SoundManager.get_music_volume() as float
	print(curr_sound)
	tw = get_tree().create_tween()
	te = get_tree().create_tween()
	te.tween_method(SoundManager.set_music_volume,SoundManager.get_music_volume(),0,5)
	tw.tween_property(eyelid_overlay, "color:a", 1, 5)
	await tw.finished

func move_people():
	if tw.is_running():
		await tw.finished
	if te.is_running():
		await te.finished
	for i in line_npcs:
		i.position.x += 30
	player.get_node("CollisionShape2D").disabled = true
	player.position = Vector2(184, 155)
	player.direction = Vector2.UP
	player.anim.play("idle_up")
	player.camera.reset_smoothing()
	tw = get_tree().create_tween()
	tw.tween_property(eyelid_overlay, "color:a", 0, 5)
	if tw.is_running():
		await tw.finished
