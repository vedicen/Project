extends Panel

@onready var dish_container =$VBoxContainer/ScrollContainer/DishContainer

@onready var search_input =$VBoxContainer/HBoxContainer/SearchInput
@onready var type_option: OptionButton = $VBoxContainer/GridContainer/TypeOption
@onready var name_input: LineEdit = $VBoxContainer/GridContainer/NameInput
@onready var calories_input: LineEdit = $VBoxContainer/GridContainer/CaloriesInput
@onready var price_input: LineEdit = $VBoxContainer/GridContainer/PriceInput
@onready var proteins_input: LineEdit = $VBoxContainer/GridContainer/ProteinsInput

var editing_dish_id = -1
var dish_card_scene =preload("res://Сцены/DayCard.tscn")


func _ready():
	type_option.add_item("breakfast")
	type_option.add_item("lunch")
	type_option.add_item("dinner")

	load_all_dishes()


func load_all_dishes():

	clear_container()

	Database.db.query("""
		SELECT * FROM dish
		ORDER BY dish_name
	""")

	var dishes =Database.db.query_result

	for dish in dishes:

		create_card(dish)




func clear_container():

	for child in dish_container.get_children():

		child.queue_free()
func create_card(dish):
	
	var card =dish_card_scene.instantiate()
	
	dish_container.add_child(card)

	await card.ready

	card.setup_dish(dish)

	card.delete_pressed.connect(
		delete_dish
	)
	card.edit_pressed.connect(
		edit_dish
	)
	
func delete_dish(dish_id):

	Database.db.query("""
		DELETE FROM dish
		WHERE id = %d
	""" % dish_id)

	load_all_dishes()
func _on_search_button_pressed():

	var text =search_input.text

	clear_container()

	Database.db.query("""
		SELECT * FROM dish
		WHERE dish_name LIKE '%%%s%%'
		ORDER BY dish_name
	""" % text)

	var dishes =Database.db.query_result

	for dish in dishes:

		create_card(dish)


func _on_back_button_pressed():

	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)

func _on_add_button_pressed():

	var dish_name =name_input.text

	var calories =calories_input.text.to_float()

	var price =price_input.text.to_float()

	var proteins =proteins_input.text.to_float()

	var dish_type =type_option.get_item_text(
			type_option.selected
		)

	if editing_dish_id == -1:

		Database.db.query("""
			INSERT INTO dish
			(
				dish_name,
				calories,
				price,
				proteins,
				fats,
				carbohydrates,
				dish_type
			)

			VALUES
			(
				'%s',
				%f,
				%f,
				%f,
				0,
				0,
				'%s'
			)
		""" % [
			dish_name,
			calories,
			price,
			proteins,
			dish_type
		])

	else:

		Database.db.query("""
			UPDATE dish

			SET
				dish_name = '%s',
				calories = %f,
				price = %f,
				proteins = %f,
				dish_type = '%s'

			WHERE id = %d
		""" % [
			dish_name,
			calories,
			price,
			proteins,
			dish_type,
			editing_dish_id
		])

		editing_dish_id = -1

	load_all_dishes()

	clear_inputs()

	Database.db.query("""
		INSERT INTO dish
		(
			dish_name,
			calories,
			price,
			proteins,
			fats,
			carbohydrates,
			dish_type
		)

		VALUES
		(
			'%s',
			%f,
			%f,
			%f,
			0,
			0,
			'%s'
		)
	""" % [
		dish_name,
		calories,
		price,
		proteins,
		dish_type
	])

	load_all_dishes()

	clear_inputs()
func clear_inputs():

	name_input.text = ""
	calories_input.text = ""
	price_input.text = ""
	proteins_input.text = ""
func edit_dish(dish_id):

	editing_dish_id = dish_id

	Database.db.query("""
		SELECT * FROM dish
		WHERE id = %d
	""" % dish_id)

	var dish =Database.db.query_result[0]

	name_input.text =dish["dish_name"]

	calories_input.text =str(dish["calories"])

	price_input.text =str(dish["price"])

	proteins_input.text =str(dish["proteins"])

	var type =dish["dish_type"]

	match type:

		"breakfast":
			type_option.select(0)

		"lunch":
			type_option.select(1)

		"dinner":
			type_option.select(2)
