extends Control

@onready var shopping_text: RichTextLabel = $VBoxContainer/shopping_text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_shopping_list()
	pass # Replace with function body.


func generate_shopping_list():
	shopping_text.text = ""
	shopping_text.fit_content = true 
	
	var ingredients_dict = {}
	Database.db.query("""
		SELECT * FROM dish
	""")
	var dishes = Database.db.query_result
	for dish in dishes:
		var dish_id = dish["id_dish"]
		
		Database.db.query("""
			SELECT ingredient.ingredient_name,
			ingredient.unit,
			dish_ingredient.quantity
			FROM dish_ingredient
			
			JOIN ingredient
			ON ingredient.id_ingredient = dish_ingredient.id_ingredient
			
			WHERE dish_ingredient.id_dish = 
		""" + str(dish_id))
		var ingredients = Database.db.query_result
		for ingredient in ingredients:
			var name = ingredient["ingredient_name"]
			var quantity = ingredient["quantity"]
			var unit = ingredient["unit"]
			if ingredients_dict.has(name):
				ingredients_dict[name]["quantity"] += quantity
			else:
					
				ingredients_dict[name] ={
					"quantity": quantity,
					"unit" : unit
				}	
	shopping_text.text += "СПИСОК ПОКУПОК\n\n"
	for name in ingredients_dict:
		var quantity = ingredients_dict[name]["quantity"]
		var unit = ingredients_dict[name]["unit"]
		
		shopping_text.text += (
			name + " - "
			+ str(quantity)
			+ " "
			+ unit + "\n"
		)


func _on_back_pressed() -> void:
		get_tree().change_scene_to_file(
		"res://Сцены/main_menu.tscn"
	) # Replace with function body.
