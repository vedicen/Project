import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../shopping/shopping_screen.dart';
import '../recipe/recipe_screen.dart';

class MenuScreen extends StatefulWidget {
  final Map menu;
  const MenuScreen({super.key, required this.menu});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Map menu;
  int selectedDay = 0;

  final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  final mealNames = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
  };
  final mealIcons = {
    'breakfast': Icons.wb_sunny_outlined,
    'lunch': Icons.soup_kitchen_outlined,
    'dinner': Icons.nightlight_outlined,
    'snack': Icons.coffee_outlined,
  };

  @override
  void initState() {
    super.initState();
    menu = widget.menu;
  }

  Future<void> _goShopping() async {
    final menuId = menu['id'];
    await ApiService.generateShopping(menuId);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ShoppingScreen(menuId: menuId),
    ));
  }

  Future<void> _saveFavorite() async {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Сохранить меню', style: TextStyle(fontSize: 15)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Название подборки',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              await ApiService.saveFavorite(menu['id'], controller.text);
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Сохранено в избранное!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  List _getMeals() {
    final days = menu['days'] as List? ?? [];
    if (days.isEmpty) return [];
    final day = days[selectedDay];
    return day['meals'] as List? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final days = menu['days'] as List? ?? [];
    final day = days.isNotEmpty ? days[selectedDay] : null;
    final meals = _getMeals();

    final dayCalories = meals.fold(0.0, (s, m) => s + (double.tryParse(m['calories'].toString()) ?? 0));
    final dayProtein = meals.fold(0.0, (s, m) => s + (double.tryParse(m['protein'].toString()) ?? 0));
    final dayFat = meals.fold(0.0, (s, m) => s + (double.tryParse(m['fat'].toString()) ?? 0));
    final dayCarbs = meals.fold(0.0, (s, m) => s + (double.tryParse(m['carbs'].toString()) ?? 0));
    final dayCost = meals.fold(0.0, (s, m) => s + (double.tryParse(m['cost'].toString()) ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text('Меню на неделю', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: _saveFavorite,
            tooltip: 'Сохранить в избранное',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: _goShopping,
            tooltip: 'Список покупок',
          ),
        ],
      ),
      body: Column(
        children: [
          // Инфо бюджет
          Container(
            color: const Color(0xFFE3F2FD),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.people_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${menu['persons_count']} чел.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.monetization_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${double.tryParse(menu['total_cost'].toString())?.toStringAsFixed(0)} / ${double.tryParse(menu['budget'].toString())?.toStringAsFixed(0)} ₽',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (double.tryParse(menu['total_cost'].toString()) ?? 0) <=
                        (double.tryParse(menu['budget'].toString()) ?? 0)
                        ? Colors.green
                        : Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (double.tryParse(menu['total_cost'].toString()) ?? 0) <=
                        (double.tryParse(menu['budget'].toString()) ?? 0)
                        ? 'В бюджете'
                        : 'Превышен',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Дни недели
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(days.length, (i) {
                  final selected = selectedDay == i;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF2196F3) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dayNames[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Блюда
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (day != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      day['day_name'] ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),

                ...meals.map((meal) => _buildMealCard(meal)),
                const SizedBox(height: 8),

                // КБЖУ за день
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('За день',
                          style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat('Ккал', dayCalories.toStringAsFixed(0)),
                          _buildStat('Белки', '${dayProtein.toStringAsFixed(0)} г'),
                          _buildStat('Жиры', '${dayFat.toStringAsFixed(0)} г'),
                          _buildStat('Углев.', '${dayCarbs.toStringAsFixed(0)} г'),
                          _buildStat('Стоимость', '${dayCost.toStringAsFixed(0)} ₽'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map meal) {
    final type = meal['meal_type'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          final recipeId = int.tryParse(meal['recipe_id'].toString()) ?? 0;
          if (recipeId > 0) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => RecipeScreen(recipeId: recipeId),
            ));
          }
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            mealIcons[type] ?? Icons.restaurant_outlined,
            color: const Color(0xFF2196F3),
            size: 20,
          ),
        ),
        title: Text(
          meal['name'] ?? '',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          mealNames[type] ?? type,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${double.tryParse(meal['calories'].toString())?.toStringAsFixed(0)} ккал',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              '${double.tryParse(meal['cost'].toString())?.toStringAsFixed(0)} ₽',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}