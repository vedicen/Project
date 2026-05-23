extends Panel

@onready var item_label =$HBoxContainer/ItemLabel

@onready var bought_check =$HBoxContainer/BoughtCheck


var item_name = ""


func setup_item(text):

	item_name = text

	item_label.text = text

	load_state()


# =====================================
# СОХРАНЕНИЕ CHECKBOX
# =====================================

func _on_bought_check_toggled(
	toggled_on
):

	save_state(toggled_on)


func save_state(value):

	Database.db.query("""

		DELETE FROM shopping_state
		WHERE item_name = '%s'

	""" % item_name)

	Database.db.query("""

		INSERT INTO shopping_state
		(
			item_name,
			is_bought
		)

		VALUES
		(
			'%s',
			%d
		)

	""" % [
		item_name,
		int(value)
	])


# =====================================
# ЗАГРУЗКА СОСТОЯНИЯ
# =====================================

func load_state():

	Database.db.query("""

		SELECT *
		FROM shopping_state

		WHERE item_name = '%s'

	""" % item_name)

	if Database.db.query_result.size() > 0:

		var row =Database.db.query_result[0]

		bought_check.button_pressed =bool(row["is_bought"])
