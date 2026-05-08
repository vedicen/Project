extends Node

var db

func _ready():

	# =====================================
	# Подключение SQLite
	# =====================================

	db = SQLite.new()

	db.path = "res://menu.db"

	db.open_db()

	print("База данных подключена")

	create_database()

# =====================================
# СОЗДАНИЕ ВСЕЙ БАЗЫ ДАННЫХ
# =====================================

func create_database():

	# =====================================
	# ПОЛЬЗОВАТЕЛЬ
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS users (
            id_user INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT,
            password TEXT
        );
	""")

	# =====================================
	# МЕНЮ
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS menu (
            id_menu INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user INTEGER,
            menu_name TEXT,
            created_at TEXT
        );
	""")

	# =====================================
	# ДЕНЬ
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS day_menu (
            id_day INTEGER PRIMARY KEY AUTOINCREMENT,
            id_menu INTEGER,
            day_name TEXT,
            total_calories REAL,
            total_price REAL
        );
	""")

	# =====================================
	# ПРИЕМ ПИЩИ
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS meal (
            id_meal INTEGER PRIMARY KEY AUTOINCREMENT,
            id_day INTEGER,
            meal_type TEXT
        );
	""")

	# =====================================
	# БЛЮДО
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS dish (
            id_dish INTEGER PRIMARY KEY AUTOINCREMENT,
            dish_name TEXT,
            description TEXT,

            calories REAL,
            proteins REAL,
            fats REAL,
            carbohydrates REAL,

            price REAL,
            dish_type TEXT
        );
	""")

	# =====================================
	# ПРИЕМ ПИЩИ - БЛЮДО
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS meal_dish (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_meal INTEGER,
            id_dish INTEGER,
            quantity INTEGER
        );
	""")

	# =====================================
	# ИНГРЕДИЕНТ
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS ingredient (
            id_ingredient INTEGER PRIMARY KEY AUTOINCREMENT,
            ingredient_name TEXT,
            unit TEXT,
            price REAL
        );
	""")

	# =====================================
	# СОСТАВ БЛЮДА
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS dish_ingredient (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_dish INTEGER,
            id_ingredient INTEGER,
            quantity REAL
        );
	""")

	# =====================================
	# СПИСОК ПОКУПОК
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS shopping_list (
            id_list INTEGER PRIMARY KEY AUTOINCREMENT,
            id_menu INTEGER
        );
	""")

	# =====================================
	# ПОЗИЦИИ СПИСКА ПОКУПОК
	# =====================================

	db.query("""
        CREATE TABLE IF NOT EXISTS shopping_list_item (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_list INTEGER,
            id_ingredient INTEGER,
            quantity REAL,
            is_bought INTEGER
        );
	""")

	print("База данных создана")

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
            ingredient_name,
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
            id_dish,
            id_ingredient,
            quantity
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



# Called when the node enters the scene tree for the first time.
