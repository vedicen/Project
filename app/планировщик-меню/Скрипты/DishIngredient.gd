extends Control

@onready var ingredient_option =$HBoxContainer/IngredientOption

@onready var amount_input =$HBoxContainer/AmountInput


var current_dish_id = 0


func _ready():

	load_ingredients()


# =====================================
# ЗАГРУЗКА ИНГРЕДИЕНТОВ
# =====================================

func load_ingredients():

	ingredient_option.clear()

	Database.db.query("""

		SELECT *
		FROM ingredient

		ORDER BY name

	""")

	var ingredients =Database.db.query_result

	for ingredient in ingredients:

		ingredient_option.add_item(
			ingredient["name"],
			ingredient["id"]
		)


# =====================================
# УСТАНОВКА БЛЮДА
# =====================================

func set_dish(dish_id):

	current_dish_id = dish_id


# =====================================
# ДОБАВЛЕНИЕ ИНГРЕДИЕНТА
# =====================================

func _on_add_button_pressed():

	var ingredient_id =ingredient_option.get_selected_id()

	var amount =amount_input.text.to_float()

	Database.db.query("""

		INSERT INTO dish_ingredient
		(
			dish_id,
			ingredient_id,
			amount
		)

		VALUES
		(
			%d,
			%d,
			%f
		)

	""" % [

		current_dish_id,
		ingredient_id,
		amount
	])

	print("Ингредиент добавлен")

	amount_input.text = ""
