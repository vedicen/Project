extends Control
@onready var week_menu: Control = $"."
@onready var menu_text: RichTextLabel = $VBoxContainer/menu_text


func _ready():
	menu_text.add_theme_color_override("font_color", Color(1,1,1))
	menu_text.add_theme_stylebox_override("normal", StyleBoxFlat.new())

	show_week_menu()

func show_week_menu():

	menu_text.text = ""
	menu_text.fit_content = true  # или используйте автоматический перенос
	menu_text.text += "ПОНЕДЕЛЬНИК\n"
	menu_text.text += "Завтрак: Омлет\n"
	menu_text.text += "Обед: Борщ\n"
	menu_text.text += "Ужин: Рис с курицей\n\n"

	menu_text.text += "ВТОРНИК\n"
	menu_text.text += "Завтрак: Каша\n"
	menu_text.text += "Обед: Суп\n"
	menu_text.text += "Ужин: Паста\n"
