class_name TheFollower extends Echidna

func attack():
	anim_player.play("attack_execute")
	bs.damage_player(1,1)
	
func wind_up():
	anim_player.play("attack_windup")
