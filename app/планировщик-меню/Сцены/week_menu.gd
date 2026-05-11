extends Control
@onready var week_menu: Control = $"."
@onready var menu_text: RichTextLabel = $VBoxContainer/menu_text


func _ready():
	menu_text.add_theme_color_override("font_color", Color(1,1,1))
	menu_text.add_theme_stylebox_override("normal", StyleBoxFlat.new())

	show_week_menu()

func show_week_menu():

	menu_text.text = ""
	menu_text.fit_content = true  
	Database.db.query("""
		SELECT * FROM dish
	""")
	#var dishes = Database.db.query_result
	
	
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
		menu_text.text += day + "\n"
		#Завтрак
		Database.db.query("""
			SELECT * FROM dish
			WHERE dish_type = 'breakfast'
			ORDER BY RANDOM()
			LIMIT 1
		""")
		var breakfast = Database.db.query_result[0]
		
		menu_text.text +="Завтрак: "
		menu_text.text += breakfast["dish_name"] + "\n"
		#ОБЕД
		Database.db.query("""
			SELECT * FROM dish
			WHERE dish_type = 'lunch'
			ORDER BY RANDOM()
			LIMIT 1
		""")
		var lunch = Database.db.query_result[0]
		menu_text.text +="Обед: "
		menu_text.text += lunch["dish_name"] + "\n"
		
		Database.db.query("""
			SELECT * FROM dish
			WHERE dish_type = 'dinner'
			ORDER BY RANDOM()
			LIMIT 1
		""")
		var dinner = Database.db.query_result[0]
		menu_text.text +="Ужин: "
		menu_text.text += dinner["dish_name"] + "\n"
	
