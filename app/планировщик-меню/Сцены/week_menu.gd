extends Control
@onready var week_menu: Control = $"."
@onready var menu_text: RichTextLabel = $VBoxContainer/menu_text
var total_week_calories = 0.0
var total_week_price = 0.0

var total_week_proteins = 0.0
var total_week_fats =0.0
var total_week_carbs = 0.0


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
		var day_calories = 0.0 
		var day_price = 0.0 
		
		var day_proteins = 0.0 
		var day_fats = 0.0 
		var day_carbs = 0.0
		menu_text.text += day + "\n"
		#Завтрак
		Database.db.query("""
			SELECT * FROM dish
			WHERE dish_type = 'breakfast'
			ORDER BY RANDOM()
			LIMIT 1
		""")
		
		var breakfast = Database.db.query_result[0]
		print(breakfast)
		
		
		menu_text.text +="Завтрак: "
		menu_text.text += breakfast["dish_name"] + "\n"
		day_calories += breakfast.get("calories", 0.0)
		day_price += breakfast.get("price", 0.0)
		
		day_proteins += breakfast.get("proteins", 0.0)
		day_fats += breakfast.get("fats", 0.0)
		day_carbs += breakfast.get("carbohydrates", 0.0)
		print(breakfast)
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
		day_calories += lunch.get("calories", 0.0)
		day_price += lunch.get("price", 0.0)
		
		day_proteins += lunch.get("proteins", 0.0)
		day_fats += lunch.get("fats", 0.0)
		day_carbs += lunch.get("carbohydrates", 0.0)
		
		Database.db.query("""
			SELECT * FROM dish
			WHERE dish_type = 'dinner'
			ORDER BY RANDOM()
			LIMIT 1
		""")
		var dinner = Database.db.query_result[0]
		menu_text.text +="Ужин: "
		menu_text.text += dinner["dish_name"] + "\n"
		day_calories += dinner.get("calories", 0.0)
		day_price += dinner.get("price", 0.0)
		
		day_proteins += dinner.get("proteins", 0.0)
		day_fats += dinner.get("fats", 0.0)
		day_carbs += dinner.get("carbohydrates", 0.0)
		menu_text.text += "\nКалорий: " + str(day_calories)
		menu_text.text += "\nБелки: " + str(day_proteins)
		menu_text.text += "\nЖиры: " + str(day_fats)
		menu_text.text += "\nУглеводы : " + str(day_carbs)
		menu_text.text += "\nСтоймость : " + str(day_price) + "Р \n\n"
		total_week_calories += day_calories
		total_week_price += day_price
		
		total_week_proteins += day_proteins
		total_week_fats += day_fats
		total_week_carbs += day_carbs
	menu_text.text += "++++++++++++++++++++++\n"
	
	menu_text.text += "ИТОГ ЗА НЕДЕЛЮ\n"	
	
	menu_text.text += "Калории: "
	menu_text.text += str(total_week_calories) + "\n"
	
	menu_text.text += "Белки: "
	menu_text.text += str(total_week_proteins)+"\n"
	
	menu_text.text += "Жиры: "
	menu_text.text += str(total_week_fats)+"\n"
	
	menu_text.text += "Углеводы: "
	menu_text.text += str(total_week_carbs)+"\n"
	
	menu_text.text += "Стоймость: "
	menu_text.text += str(total_week_price)+"\n"
	
