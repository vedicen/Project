extends Node3D

var follow_player = false
@export var exp = 1
func _process(delta):
	if follow_player and Global.player:
		global_position = global_position.lerp(
			Global.player.global_position,
			delta * 5.0
		)

func _on_chese_area_body_entered(body):
	if body == Global.player:
		follow_player = true

func _on_chese_area_body_exited(body):
	if body == Global.player:
		follow_player = false

func _on_get_area_body_entered(body):
	Skil.add_exp(exp)
	queue_free()
	pass
