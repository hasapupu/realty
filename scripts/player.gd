class_name Player extends CharacterBody2D
@export var speed : float = 50
@onready var direction : Vector2 = Vector2.ZERO
@onready var raycast : RayCast2D = $RayCast2D
var npc: Intractable
var active: bool = false #NOT OBVIOUS MEANING, IRONICALLY MEANS "CUTSCENE IS ACTIVE", SO PLAYER IS INACTIVE!!!!
@onready var anim:AnimationPlayer = $AnimationPlayer
var idle_dir : String = "idle"
@export var inventory := []
@onready var inventory_node: Control = $Camera2D/Control
@onready var curr_item:Item
@onready var camera:Camera2D = $Camera2D
@onready var nav_agent:NavigationAgent2D = $NavigationAgent2D
@export var nav_speed := 20
var naving := false:
	set(value):
		if value == false:
			emit_signal("finished_naving")
		naving = value
var nav_dir := Vector2.ZERO
signal finished_naving
func nav_to(x,y):
	nav_agent.target_position = Vector2(x,y)
	naving = true
	await finished_naving

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
var in_cuts := false #USE ONLY WHEN PLAYER IS BEING ANIMATED IN CUTS, FOR CHECKS AND DISABLES USE "active"

func _ready() -> void:
	inventory_node.visible = false


func _process(delta: float) -> void:
	inventory_node.set_process(inventory_node.visible)
	if Vector2.ZERO == direction:
		raycast.enabled = false
		if !in_cuts:
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
	var nav_p_dir = Vector2.ZERO
	if !nav_agent.is_target_reached():
		if naving:
			nav_p_dir = global_position.direction_to(
	nav_agent.get_next_path_position()
)
			print(nav_agent.target_position)
			print(nav_p_dir)
			print(nav_agent.distance_to_target())
	else:
		naving = false
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
		if Input.is_action_just_pressed("ui_accept") or npc.forced:
			DialogueManager.show_dialogue_balloon(load(npc.dialogue_path),"start",[self, get_parent().get_parent()])
			active = true
			await DialogueManager.dialogue_ended
			active = false
	if !active:
		velocity = direction * speed
	elif naving:
		velocity = nav_p_dir * nav_speed 
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
	DialogueManager.show_dialogue_balloon(load(inventory[index].item_use_text_path),"start",[self, get_parent().get_parent()])
	await DialogueManager.dialogue_ended
	hp += inventory[index].heal_amount
	active = false
