class_name BattleTimer extends Timer

var bs :BattleSequence
var player_index:= 0
var e_attack_index:= 0
var e_fakeout_index:= 0
var curr_time:float =0
signal player_note(duration:float)
signal enemy_attack
signal enemy_fakeout

func _process(delta: float) -> void:
	curr_time = wait_time-time_left
	if self.is_stopped() == false and self.paused == false:
		if player_index < bs.player_notes.size() - 1 and bs.player_notes[player_index] <= curr_time:
				#print(bs.player_notes[player_index + 1])
				#print(bs.player_notes[player_index])
				#print(curr_time)
			player_note.emit(bs.enemy.input_rate)
			player_index += 1
		if bs.enemy_attack_notes.size() > 0 and bs.enemy_attack_notes[e_attack_index] <= curr_time:
			enemy_attack.emit()
			e_attack_index += 1
		if bs.enemy_fakeout_notes.size() > 0 and bs.enemy_fakeout_notes[e_fakeout_index] <= curr_time:
			enemy_fakeout.emit()
			e_fakeout_index += 1

func _on_timeout() -> void:
	player_index = 0
	e_attack_index = 0
	e_fakeout_index = 0
