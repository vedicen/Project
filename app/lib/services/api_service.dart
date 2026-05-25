import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/menu_api';

  // Получить токен из хранилища
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Сохранить токен
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Сохранить данные пользователя
  static Future<void> saveUser(Map user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  // Получить данные пользователя
  static Future<Map?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('user');
    if (str == null) return null;
    return jsonDecode(str);
  }

  // Выйти
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Регистрация
  static Future<Map> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth.php?action=register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // Вход
  static Future<Map> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth.php?action=login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }
  // Получить все ингредиенты
  static Future<List> getAllIngredients() async {
    final res = await http.get(Uri.parse('$baseUrl/ingredients.php?action=all'));
    return jsonDecode(res.body);
  }

// Добавить рецепт
  static Future<Map> addRecipe(Map data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/recipes.php?action=add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  // Генерация меню
  static Future<Map> generateMenu(int userId, int persons, double budget) async {
    final res = await http.post(
      Uri.parse('$baseUrl/menu.php?action=generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'persons_count': persons, 'budget': budget}),
    );
    return jsonDecode(res.body);
  }

  // Получить меню
  static Future<Map> getMenu(int menuId) async {
    final res = await http.get(Uri.parse('$baseUrl/menu.php?action=get&id=$menuId'));
    return jsonDecode(res.body);
  }

  // Все рецепты
  static Future<List> getRecipes({String type = ''}) async {
    final url = type.isEmpty
        ? '$baseUrl/recipes.php?action=all'
        : '$baseUrl/recipes.php?action=all&type=$type';
    final res = await http.get(Uri.parse(url));
    return jsonDecode(res.body);
  }

  // Один рецепт
  static Future<Map> getRecipe(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/recipes.php?action=get&id=$id'));
    return jsonDecode(res.body);
  }

  // Заменить блюдо
  static Future<Map> replaceMeal(int mealId, int recipeId) async {
    final res = await http.put(
      Uri.parse('$baseUrl/menu.php?action=replace_meal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'meal_id': mealId, 'recipe_id': recipeId}),
    );
    return jsonDecode(res.body);
  }

  // Сформировать список покупок
  static Future<List> generateShopping(int menuId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/shopping.php?action=generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'menu_id': menuId}),
    );
    return jsonDecode(res.body);
  }

  // Получить список покупок
  static Future<List> getShopping(int menuId) async {
    final res = await http.get(Uri.parse('$baseUrl/shopping.php?action=get&menu_id=$menuId'));
    return jsonDecode(res.body);
  }

  // Отметить купленным
  static Future<void> setBought(int id, bool bought) async {
    await http.put(
      Uri.parse('$baseUrl/shopping.php?action=bought'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'is_bought': bought ? 1 : 0}),
    );
  }

  // Изменить цену
  static Future<void> setPrice(int id, double price) async {
    await http.put(
      Uri.parse('$baseUrl/shopping.php?action=price'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'price': price}),
    );
  }

  // Избранные меню
  static Future<List> getFavorites(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/menu.php?action=favorites&user_id=$userId'));
    return jsonDecode(res.body);
  }

  // Сохранить в избранное
  static Future<void> saveFavorite(int menuId, String name) async {
    await http.put(
      Uri.parse('$baseUrl/menu.php?action=favorite'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'menu_id': menuId, 'name': name}),
    );
  }
}