extends Panel

@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var day_label: Label = $VBoxContainer/DayLabel
@onready var lunch_label: Label = $VBoxContainer/LunchLabel
@onready var dinner_label: Label = $VBoxContainer/DinnerLabel
@onready var calories_label: Label = $VBoxContainer/CaloriesLabel
@onready var price_label: Label = $VBoxContainer/PriceLabel
@onready var breakfast_label: Label = $VBoxContainer/BreakfastLabel


func _ready():

	print(day_label)
	print(breakfast_label)
	print(lunch_label)
	print(dinner_label)
	print(calories_label)
	print(price_label)

func setup_day(data):

	day_label.text = data["day"]

	breakfast_label.text =  data["breakfast"]

	lunch_label.text = data["lunch"]

	dinner_label.text =  data["dinner"]

	calories_label.text ="Ккал: " + str(data["calories"])

	price_label.text = "Цена: " + str(data["price"]) + " ₽"
