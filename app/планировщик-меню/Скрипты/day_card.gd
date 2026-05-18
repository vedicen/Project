extends Panel

signal delete_pressed

var dish_id = 0


@onready var name_label =$VBoxContainer/NameLabel

@onready var calories_label =$VBoxContainer/CaloriesLabel

@onready var price_label =$VBoxContainer/PriceLabel

@onready var type_label =$VBoxContainer/TypeLabel


func setup_dish(data):

	dish_id = data["id"]

	name_label.text =data["dish_name"]

	calories_label.text ="Ккал: " +str(data["calories"])

	price_label.text ="Цена: " +str(data["price"]) +" ₽"

	type_label.text ="Тип: " +data["dish_type"]


func _on_delete_button_pressed():

	delete_pressed.emit(dish_id)


func _on_edit_button_pressed() -> void:
	pass # Replace with function body.
