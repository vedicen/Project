extends Control
@onready var day_label: Label = $Panel/VBoxContainer/DayLabel

@onready var breakfast_label: Label = $Panel/VBoxContainer/BreakfastLabel
@onready var lunch_label: Label = $Panel/VBoxContainer/LunchLabel
@onready var dinner_label: Label = $Panel/VBoxContainer/DinnerLabel
@onready var calories_label: Label = $Panel/VBoxContainer/CaloriesLabel
@onready var price_label: Label = $Panel/VBoxContainer/PriceLabel




func setup_day(data):

	day_label.text = data["day"]

	breakfast_label.text =  data["breakfast"]

	lunch_label.text = data["lunch"]

	dinner_label.text =  data["dinner"]

	calories_label.text ="Ккал: " + str(data["calories"])

	price_label.text = "Цена: " + str(data["price"]) + " ₽"
