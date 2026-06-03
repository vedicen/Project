extends Node
var critikl_dmg = 0
var bonus_hp = 0
var bonus_dmg = 0
var bonus_speed = 0
var bonus_speed_attack = 0
var exp = 0
var level = 0
func add_exp(n):
	exp += n
	if exp > 10:
		level +=1
		Global.player.level_up()
		exp = 0
	
