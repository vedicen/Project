extends Control

@onready var persons_input = $VBoxContainer/SpinBox
@onready var budget_input = $VBoxContainer/LineEdit

func _on_generate_pressed():

	var persons = persons_input.value
	var budget = budget_input.text.to_float()

	print("Персон: ", persons)
	print("Бюджет: ", budget)

	generate_week_menu(persons, budget)

func generate_week_menu(persons, budget):

	print("Генерация меню...")
