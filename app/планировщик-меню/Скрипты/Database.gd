extends Node

var db


func _ready():

	# =====================================
	# ПОДКЛЮЧЕНИЕ SQLITE
	# =====================================

	db = SQLite.new()

	db.path = "res://menu.db"

	db.open_db()

	print("База данных подключена")

	create_tables()


# =====================================
# СОЗДАНИЕ ТАБЛИЦ
# =====================================

func create_tables():

	# =====================================
	# ТАБЛИЦА БЛЮД
	# =====================================
	db.query("""

	CREATE TABLE IF NOT EXISTS shopping_state (

		id INTEGER PRIMARY KEY AUTOINCREMENT,

		item_name TEXT,
		is_bought INTEGER
	)

""")

	db.query("""

		CREATE TABLE IF NOT EXISTS dish (

			id INTEGER PRIMARY KEY AUTOINCREMENT,

			dish_name TEXT,
			description TEXT,

			calories REAL,

			proteins REAL,
			fats REAL,
			carbohydrates REAL,

			price REAL,

			dish_type TEXT
		)

	""")


	# =====================================
	# ТАБЛИЦА ИНГРЕДИЕНТОВ
	# =====================================

	db.query("""

		CREATE TABLE IF NOT EXISTS ingredient (

			id INTEGER PRIMARY KEY AUTOINCREMENT,

			name TEXT,
			unit TEXT,
			price REAL
		)

	""")


	# =====================================
	# СВЯЗЬ БЛЮД И ИНГРЕДИЕНТОВ
	# =====================================

	db.query("""

		CREATE TABLE IF NOT EXISTS dish_ingredient (

			id INTEGER PRIMARY KEY AUTOINCREMENT,

			dish_id INTEGER,
			ingredient_id INTEGER,

			amount REAL
		)

	""")


	# =====================================
	# СОХРАНЕННОЕ МЕНЮ
	# =====================================

	db.query("""

		CREATE TABLE IF NOT EXISTS saved_menu (

			id INTEGER PRIMARY KEY AUTOINCREMENT,

			day_name TEXT,

			breakfast TEXT,
			lunch TEXT,
			dinner TEXT
		)

	""")


	insert_test_data()


# =====================================
# ТЕСТОВЫЕ ДАННЫЕ
# =====================================

func insert_test_data():

	# Проверка есть ли блюда

	db.query("SELECT * FROM dish;")

	if db.query_result.size() > 0:

		print("Данные уже существуют")

		return


	# =====================================
	# БЛЮДА
	# =====================================

	db.query("""

		INSERT INTO dish
		(
			dish_name,
			description,

			calories,

			proteins,
			fats,
			carbohydrates,

			price,

			dish_type
		)

		VALUES

		(
			'Омлет',
			'Классический омлет',

			250,

			12,
			18,
			4,

			80,

			'breakfast'
		),

		(
			'Борщ',
			'Домашний борщ',

			340,

			15,
			10,
			25,

			170,

			'lunch'
		),

		(
			'Рис с курицей',
			'Курица с рисом',

			520,

			30,
			12,
			55,

			230,

			'dinner'
		);

	""")


	# =====================================
	# ИНГРЕДИЕНТЫ
	# =====================================

	db.query("""

		INSERT INTO ingredient
		(
			name,
			unit,
			price
		)

		VALUES

		('Картофель', 'кг', 70),

		('Курица', 'кг', 320),

		('Рис', 'кг', 110),

		('Яйца', 'шт', 12),

		('Молоко', 'л', 95),

		('Свекла', 'кг', 85);

	""")


	# =====================================
	# СОСТАВ БЛЮД
	# =====================================

	db.query("""

		INSERT INTO dish_ingredient
		(
			dish_id,
			ingredient_id,
			amount
		)

		VALUES

		(1, 4, 2),
		(1, 5, 0.2),

		(2, 1, 0.3),
		(2, 6, 0.2),

		(3, 2, 0.3),
		(3, 3, 0.2);

	""")


	print("Тестовые данные добавлены")


# =====================================
# КНОПКА НАЗАД
# =====================================

func _on_back_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Сцены/main_menu.tscn"
	)
