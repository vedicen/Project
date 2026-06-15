extends CharacterBody3D
class_name Entity

@export var max_hp: int = 100
@export var base_damage: int = 25
@export var base_crit_chance: int = 10
@export var base_crit_damage: int = 110
@export var regen_hp: int = 5
@export var speed: int = 5

var current_hp: int
var level: int = 1
var exp: int = 0
var next_level: int = 10

func _ready():
	current_hp = get_max_hp()

func get_max_hp() -> int:
	return max_hp + (level - 1) * 20

func get_damage() -> int:
	return base_damage + (level - 1) * 5

func get_crit_chance() -> int:
	return base_crit_chance + (level - 1)

func get_crit_damage() -> int:
	return base_crit_damage + (level - 1) * 5

func add_exp(amount: int):
	exp += amount
	while exp >= next_level:
		level_up()

func level_up():
	exp -= next_level
	level += 1
	next_level = int(next_level * 1.2)
	current_hp = get_max_hp()
	print("%s повысил уровень до %d!" % [name, level])

func take_damage(amount: int):
	current_hp -= amount
	if current_hp <= 0:	
		die()

func die():
	queue_free()
