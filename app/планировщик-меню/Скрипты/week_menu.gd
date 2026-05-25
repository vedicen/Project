extends Control
class_name WeekMenu
@onready var days_container =$Panel/VBoxContainer/ScrollContainer/DaysContainer

@onready var persons_input =$Panel/VBoxContainer/HBoxContainer/PersonsInput

@onready var budget_input =$Panel/VBoxContainer/HBoxContainer/BudgetInput


var day_card_scene =preload("res://Сцены/DayCard.tscn")

static var week_menu = []
var used_dishes = []


func _ready():

	randomize()


func _on_generate_button_pressed():

	generate_week_menu()


func generate_week_menu():

	# Очистка старых карточек
	for child in days_container.get_children():

		child.queue_free()

	week_menu.clear()

	used_dishes.clear()

	# Получение данных
	var persons =persons_input.text.to_int()

	var budget =budget_input.text.to_float()

	# Проверка
	if persons <= 0:

		persons = 1

	if budget <= 0:

		budget = 10000

	var current_budget = 0.0

	# Дни недели
	var days = [

		"Понедельник",
		"Вторник",
		"Среда",
		"Четверг",
		"Пятница",
		"Суббота",
		"Воскресенье"
	]

	# Генерация
	for day in days:

		var breakfast =get_random_dish(
				"breakfast"
			)

		var lunch =get_random_dish(
				"lunch"
			)

		var dinner =get_random_dish(
				"dinner"
			)

		# Стоимость дня
		var day_price =(
				breakfast["price"] +
				lunch["price"] +
				dinner["price"]
			) * persons

		# Проверка бюджета
		if current_budget + day_price > budget:

			break

		current_budget += day_price

		# Калории
		var day_calories =breakfast["calories"] +lunch["calories"] +dinner["calories"]

		# Создание карточки
		var card =day_card_scene.instantiate()

		days_container.add_child(card)

		await card.ready

		card.setup_day({

			"day": day,

			"breakfast":
				breakfast["dish_name"],

			"lunch":
				lunch["dish_name"],

			"dinner":
				dinner["dish_name"],

			"calories":
				day_calories,

			"price":
				day_price
		})

		# Сохранение меню
		week_menu.append({

			"day": day,

			"breakfast":
				breakfast,

			"lunch":
				lunch,

			"dinner":
				dinner
		})


func get_random_dish(type):

	Database.db.query("""
		SELECT * FROM dish
		WHERE dish_type = '%s'
		ORDER BY RANDOM()
	""" % type)

	var dishes =Database.db.query_result

	for dish in dishes:

		if not used_dishes.has(
			dish["id"]
		):

			used_dishes.append(
				dish["id"]
			)

			return dish

	# Если все блюда уже были
	return dishes[0]


func save_week_menu():

	Database.db.query("""
		DELETE FROM saved_menu
	""")

	for day_data in week_menu:

		var day_name =day_data["day"]

		var breakfast =day_data["breakfast"]["dish_name"]

		var lunch =day_data["lunch"]["dish_name"]

		var dinner =day_data["dinner"]["dish_name"]

		Database.db.query("""
			INSERT INTO saved_menu
			(
				day_name,
				breakfast,
				lunch,
				dinner
			)

			VALUES
			(
				'%s',
				'%s',
				'%s',
				'%s'
			)
		""" % [

			day_name,
			breakfast,
			lunch,
			dinner
		])


func _on_save_button_pressed():

	save_week_menu()

	print("Меню сохранено")


func _on_back_button_pressed():

	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)
