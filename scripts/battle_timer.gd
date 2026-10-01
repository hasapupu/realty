class_name BattleTimer extends Timer

var bs :BattleSequence
var player_index:= 0
var e_attack_index:= 0
var e_fakeout_index:= 0
var curr_time:=0
signal player_note
signal enemy_attack
signal enemy_fakeout

func _process(delta: float) -> void:
	curr_time = wait_time-time_left
	if self.is_stopped() == false and self.paused == false:
		if bs.player_notes[player_index] >= curr_time:
			player_note.emit()
			player_index += 1
		if bs.enemy_attack_notes[e_attack_index] >= curr_time:
			enemy_attack.emit()
			e_attack_index += 1
		if bs.enemy_fakeout_notes[player_index] >= curr_time:
			enemy_fakeout.emit()
			e_fakeout_index += 1

func _on_timeout() -> void:
	player_index = 0
	e_attack_index = 0
	e_fakeout_index = 0
