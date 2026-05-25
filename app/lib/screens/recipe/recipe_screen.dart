import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RecipeScreen extends StatefulWidget {
  final int recipeId;
  const RecipeScreen({super.key, required this.recipeId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  Map? recipe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getRecipe(widget.recipeId);
    setState(() { recipe = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: Text(recipe?['name'] ?? 'Рецепт', style: const TextStyle(fontSize: 16)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
          ? const Center(child: Text('Рецепт не найден'))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // КБЖУ
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('КБЖУ на порцию',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildKbju('Калории', '${double.tryParse(recipe!['calories']?.toString() ?? '0')?.toStringAsFixed(0)}', 'ккал'),
                    _buildKbju('Белки', '${double.tryParse(recipe!['protein']?.toString() ?? '0')?.toStringAsFixed(1)}', 'г'),
                    _buildKbju('Жиры', '${double.tryParse(recipe!['fat']?.toString() ?? '0')?.toStringAsFixed(1)}', 'г'),
                    _buildKbju('Углев.', '${double.tryParse(recipe!['carbs']?.toString() ?? '0')?.toStringAsFixed(1)}', 'г'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${recipe!['cook_time_minutes']} мин',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 16),
                    const Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${double.tryParse(recipe!['cost']?.toString() ?? '0')?.toStringAsFixed(0)} ₽',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Ингредиенты
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ингредиенты',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ...(recipe!['ingredients'] as List? ?? []).map((ing) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(ing['name'] ?? '',
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text(
                            '${double.tryParse(ing['quantity'].toString())?.toStringAsFixed(0)} ${ing['unit']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${double.tryParse(ing['cost'].toString())?.toStringAsFixed(0)} ₽',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3)),
                          ),
                        ],
                      ),
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Описание
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Приготовление',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Text(recipe!['description'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKbju(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}