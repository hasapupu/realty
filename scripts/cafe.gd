class_name CafeContext extends SceneContext

@onready var overlay : TileMapLayer = $YSort/TileMapLayer4
@onready var poster_npc = $NPCs/Intractable4
@onready var loverboy = $YSort/Sprite2D13
@onready var player:Player = $YSort/CharacterBody2D
@onready var loverboy_npx = $NPCs/Intractable6
@onready var barista_npc = $YSort/Sprite2D/Intractable
@onready var love_particles = $Background/CPUParticles2D
@onready var barrier = $NPCs/Intractable18

func _ready():
	if local_save.flags.has("poster") and local_save.flags["poster"]:
		hide_poster()
	if local_save.flags.has("obstacle"):
		barrier.queue_free()

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
