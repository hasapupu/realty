class_name CafeContext extends SceneContext

@onready var overlay : TileMapLayer = $YSort/TileMapLayer4
@onready var poster_npc = $NPCs/Intractable4
@onready var loverboy = $YSort/Sprite2D13
@onready var player:Player = $YSort/CharacterBody2D
@onready var loverboy_npx = $NPCs/Intractable6

func hide_poster():
	overlay.visible = true
	poster_npc.queue_free()
	
func move_lover(x,y):
	loverboy_npx.queue_free()
	loverboy.get_node("AnimationPlayer").play("walk_right")
	loverboy.nav_to(x,y)
	await loverboy.path_done
	loverboy.get_node("AnimationPlayer").play("look_up")
	
func move_player(x,y):
	player.in_cuts = true
	player.anim.play("walk_up")
	await get_tree().create_timer(1)
	await player.nav_to(x,y)
	player.idle_dir = "idle_down"
	player.in_cuts = false
