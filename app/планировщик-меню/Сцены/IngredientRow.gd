extends Control


@onready var name_label =$HBoxContainer/NameLabel

@onready var amount_label =$HBoxContainer/AmountLabel


func setup_row(data):

	name_label.text =data["name"]

	amount_label.text =str(data["amount"])+ " "+ data["unit"]
