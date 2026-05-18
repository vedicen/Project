extends Control




func _on_generate_button_pressed() -> void:
		get_tree().change_scene_to_file(
		"res://Сцены/WeekMenu.tscn"
		
	)


func _on_shopping_button_pressed() -> void:
		get_tree().change_scene_to_file(
		"res://Сцены/ShoppingList.tscn"
		
	)

func _on_dish_button_pressed() -> void:
		get_tree().change_scene_to_file(
		"res://Сцены/DateBase.tscn"
		
	)
