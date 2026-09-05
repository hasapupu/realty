class_name Player extends CharacterBody2D
@export var speed : float = 50
@onready var direction : Vector2 = Vector2.ZERO
@onready var raycast : RayCast2D = $RayCast2D
var npc: Intractable
var active: bool = false
@onready var anim:AnimationPlayer = $AnimationPlayer
var idle_dir : String = "idle"
@export var inventory := []
@onready var inventory_node: Control = $Camera2D/Control
@onready var curr_item:Item
var hp:int:
	set(value):
		if value > max_hp:
			hp = max_hp
		elif value <= 0:
			died.emit()
		else:
			hp = value
var max_hp:int
signal died

func _ready() -> void:
	inventory_node.visible = false
	SoundManager.play_music(load("res://audio/music/coffeeshop.wav"),1,"music")
	SoundManager.set_music_volume(.4)

func _process(delta: float) -> void:
	inventory_node.set_process(inventory_node.visible)
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
	if inventory_node.visible == true:
		if Input.is_action_just_pressed("ui_cancel"):
			active = false
			inventory_node.visible = false

func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	if !active:
		direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down").normalized() 
	raycast.target_position = direction * 15
	if Input.is_action_just_pressed("inventory"):
		if inventory_node.visible == false:
			if active == false:
				inventory_node.visible = true
				active = true
				var item_list:ItemList = inventory_node.get_node("NinePatchRect/ItemList")
				item_list.clear()
				for i:Item in inventory:
					item_list.add_item(i.name)
				if item_list.item_count > 0:
					item_list.select(0)
				item_list.grab_focus()
	if raycast.is_colliding():
		if raycast.get_collider() is Intractable:
			npc = raycast.get_collider()
	if raycast.is_colliding() and !active:
		if Input.is_action_just_pressed("ui_accept"):
			DialogueManager.show_dialogue_balloon(load(npc.dialogue_path),"start",[self])
			active = true
			await DialogueManager.dialogue_ended
			active = false
	if !active:
		velocity = direction * speed
	if !active:
		move_and_slide() 
		
func add_item(i:String):
	inventory.append(load(i))
	
func remove_item(i:String):
	for j in inventory:
		if j.name == i:
			inventory.erase(j)


func _on_item_list_item_activated(index: int) -> void:
	inventory_node.visible = false
	curr_item = inventory[index]
	DialogueManager.show_dialogue_balloon(load(inventory[index].item_use_text_path),"start",[self])
	await DialogueManager.dialogue_ended
	hp += inventory[index].heal_amount
	active = false
