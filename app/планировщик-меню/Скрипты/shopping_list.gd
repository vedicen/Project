extends Control

@onready var items_container =$Panel/VBoxContainer/ScrollContainer/ItemsContainer


var shopping_item_scene =preload("res://Сцены/ShoppingItem.tscn")


func _ready():

	generate_shopping_list()


# =====================================
# ГЕНЕРАЦИЯ СПИСКА ПОКУПОК
# =====================================

func generate_shopping_list():

	clear_container()

	var ingredients = {}

	# =====================================
	# ПРОХОД ПО ВСЕМ ДНЯМ
	# =====================================

	for day_data in WeekMenu.week_menu:

		add_dish_ingredients(
			day_data["breakfast"]["id"],
			ingredients
		)

		add_dish_ingredients(
			day_data["lunch"]["id"],
			ingredients
		)

		add_dish_ingredients(
			day_data["dinner"]["id"],
			ingredients
		)

	# =====================================
	# СОЗДАНИЕ КАРТОЧЕК
	# =====================================

	for ingredient_name in ingredients.keys():

		var item =shopping_item_scene.instantiate()

		items_container.add_child(item)

		await item.ready

		item.setup_item(

			ingredient_name
			+ " — "
			+ str(
				ingredients[
					ingredient_name
				]["amount"]
			)
			+ " "
			+ ingredients[
				ingredient_name
			]["unit"]
		)


# =====================================
# ДОБАВЛЕНИЕ ИНГРЕДИЕНТОВ БЛЮДА
# =====================================

func add_dish_ingredients(
	dish_id,
	ingredients
):

	Database.db.query("""

		SELECT
			ingredient.name,
			ingredient.unit,
			dish_ingredient.amount

		FROM dish_ingredient

		JOIN ingredient

		ON ingredient.id =
		dish_ingredient.ingredient_id

		WHERE dish_ingredient.dish_id = %d

	""" % dish_id)

	var result =Database.db.query_result

	for row in result:

		var ingredient_name =row["name"]

		# =====================================
		# ЕСЛИ ИНГРЕДИЕНТА НЕТ
		# =====================================

		if not ingredients.has(
			ingredient_name
		):

			ingredients[
				ingredient_name
			] = {

				"amount": 0,

				"unit":
					row["unit"]
			}

		# =====================================
		# СУММИРОВАНИЕ
		# =====================================

		ingredients[
			ingredient_name
		]["amount"] += row["amount"]


# =====================================
# ОЧИСТКА КОНТЕЙНЕРА
# =====================================

func clear_container():

	for child in items_container.get_children():

		child.queue_free()


# =====================================
# КНОПКА НАЗАД
# =====================================

func _on_back_button_pressed():

	get_tree().change_scene_to_file(
		"res://Сцены/main_menu.tscn"
	)
