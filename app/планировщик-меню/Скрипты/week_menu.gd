extends Control

@onready var days_container = $ScrollContainer/DaysContainer

var day_card_scene = preload("res://Сцены/DayCard.tscn")

# Хранение меню
var week_menu = []

# Итоги недели
var total_week_calories = 0.0
var total_week_price = 0.0

var total_week_proteins = 0.0
var total_week_fats = 0.0
var total_week_carbs = 0.0


func _ready():

	randomize()

	show_week_menu()


func show_week_menu():

	# Очистка старых карточек
	for child in days_container.get_children():

		child.queue_free()

	week_menu.clear()

	total_week_calories = 0.0
	total_week_price = 0.0

	total_week_proteins = 0.0
	total_week_fats = 0.0
	total_week_carbs = 0.0

	var days = [
		"Понедельник",
		"Вторник",
		"Среда",
		"Четверг",
		"Пятница",
		"Суббота",
        "Воскресенье"
	]

	for day in days:

		# Данные дня
		var day_data = {}

		# Статистика дня
		var day_calories = 0.0
		var day_price = 0.0

		var day_proteins = 0.0
		var day_fats = 0.0
		var day_carbs = 0.0

		# ЗАВТРАК


		Database.db.query("""
            SELECT * FROM dish
            WHERE dish_type = 'breakfast'
            ORDER BY RANDOM()
            LIMIT 1
		""")

		var breakfast =Database.db.query_result[0]

		day_data["breakfast"] = breakfast

		day_calories +=breakfast.get("calories", 0.0)

		day_price += breakfast.get("price", 0.0)

		day_proteins +=breakfast.get("proteins", 0.0)

		day_fats += breakfast.get("fats", 0.0)

		day_carbs += breakfast.get(
				"carbohydrates",
				0.0
			)

		# --------------------
		# ОБЕД
		# --------------------

		Database.db.query("""
            SELECT * FROM dish
            WHERE dish_type = 'lunch'
            ORDER BY RANDOM()
            LIMIT 1
		""")

		var lunch =Database.db.query_result[0]

		day_data["lunch"] =lunch

		day_calories +=lunch.get("calories", 0.0)

		day_price +=lunch.get("price", 0.0)

		day_proteins +=lunch.get("proteins", 0.0)

		day_fats += lunch.get("fats", 0.0)

		day_carbs += lunch.get(
				"carbohydrates",
				0.0
			)


		# УЖИН


		Database.db.query("""
            SELECT * FROM dish
            WHERE dish_type = 'dinner'
            ORDER BY RANDOM()
            LIMIT 1
		""")

		var dinner = Database.db.query_result[0]

		day_data["dinner"] =  dinner

		day_calories +=dinner.get("calories", 0.0)

		day_price +=dinner.get("price", 0.0)

		day_proteins +=dinner.get("proteins", 0.0)

		day_fats += dinner.get("fats", 0.0)

		day_carbs += dinner.get(
				"carbohydrates",
				0.0
			)

		# СОХРАНЕНИЕ ДНЯ

		day_data["day"] = day

		week_menu.append(day_data)


		# ИТОГИ НЕДЕЛИ
   

		total_week_calories +=day_calories

		total_week_price +=day_price

		total_week_proteins +=day_proteins

		total_week_fats +=day_fats

		total_week_carbs += day_carbs


		# СОЗДАНИЕ КАРТОЧКИ
 

		var card = day_card_scene.instantiate()

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

		days_container.add_child(card)


func replace_random_dish():

	if week_menu.size() == 0:
		return

	var random_day =randi() % week_menu.size()

	Database.db.query("""
        SELECT * FROM dish
        WHERE dish_type = 'dinner'
        ORDER BY RANDOM()
        LIMIT 1
	""")

	var new_dinner = Database.db.query_result[0]

	week_menu[random_day]["dinner"] = new_dinner

	show_week_menu()


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


func _on_replace_button_pressed():

	replace_random_dish()


func _on_save_button_pressed():

	save_week_menu()

	print("Меню сохранено")
