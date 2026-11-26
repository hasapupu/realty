class_name BattleTimer extends Timer

var bs :BattleSequence
var player_index:= 0
var e_attack_index:= 0
var curr_time:float =0
signal player_note()
signal enemy_attack

func _process(delta: float) -> void:
	curr_time = wait_time - time_left

	if is_stopped() or paused:
		return

	if player_index < bs.player_notes.size():
		if bs.player_notes[player_index] <= curr_time:
			player_note.emit()
			player_index += 1

	if e_attack_index < bs.enemy_attack_notes.size():
		if bs.enemy_attack_notes[e_attack_index] <= curr_time:
			e_attack_index += 1
			enemy_attack.emit()


func _on_timeout() -> void:
	player_index = 0
	e_attack_index = 0
