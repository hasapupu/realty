class_name Player extends CharacterBody2D
@export var speed : float = 50
@onready var direction : Vector2 = Vector2.ZERO
@onready var raycast : RayCast2D = $RayCast2D
var npc: Intractable
var active: bool = false
@onready var anim:AnimationPlayer = $AnimationPlayer
var idle_dir : String = "idle"

func _ready() -> void:
	SoundManager.play_music(load("res://audio/music/coffeeshop.wav"),1,"music")
	SoundManager.set_music_volume(.4)

func _process(delta: float) -> void:
	if Vector2.ZERO == direction:
		raycast.enabled = false
		anim.play(idle_dir)
	else:
		raycast.enabled = true
		if direction.x != 0:
			if direction.x < 0:
				anim.play("walk_left")
				idle_dir = "idle_left"
			else:
				anim.play("walk_right")
				idle_dir = "idle_right"
		else:
			if direction.y < 0:
				anim.play("walk_up")
				idle_dir = "idle_up"
			else:
				anim.play("walk_down")
				idle_dir = "idle"

func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	if !active:
		direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down").normalized() 
	raycast.target_position = direction * 15
	if raycast.is_colliding():
		if raycast.get_collider() is Intractable:
			npc = raycast.get_collider()
	if raycast.is_colliding() and !active:
		if Input.is_action_just_pressed("ui_accept"):
			DialogueManager.show_dialogue_balloon(load(npc.dialogue_path),"start")
			active = true
			await DialogueManager.dialogue_ended
			active = false
	if !active:
		velocity = direction * speed
	if !active:
		move_and_slide() 
