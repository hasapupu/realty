class_name NavNPC extends CharacterBody2D

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
var naving := false:
	set(value):
		if value == false:
			path_done.emit()
		naving = value
@export var nav_speed := 20
signal path_done

func nav_to(x,y):
	nav_agent.target_position = Vector2(x,y)
	naving = true

func _physics_process(delta: float) -> void:
	var nav_p_dir = Vector2.ZERO
	if !nav_agent.is_target_reached():
		if naving:
			nav_p_dir = global_position.direction_to(nav_agent.get_next_path_position())
	else:
		naving = false
	velocity = nav_p_dir * nav_speed
	if naving:
		move_and_slide()
