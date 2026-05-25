import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  String mealType = 'breakfast';
  int cookTime = 20;
  bool isLoading = false;

  List allIngredients = [];
  List<Map> selectedIngredients = [];

  final mealTypes = {
    'breakfast': 'Завтрак',
    'lunch': 'Обед',
    'dinner': 'Ужин',
    'snack': 'Перекус',
  };

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  Future<void> _loadIngredients() async {
    final data = await ApiService.getAllIngredients();
    setState(() => allIngredients = data);
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (_) {
        int? selectedId;
        String? selectedName;
        String? selectedUnit;
        final qtyController = TextEditingController();

        return StatefulBuilder(
          builder: (ctx, setS) => AlertDialog(
            title: const Text('Добавить ингредиент', style: TextStyle(fontSize: 15)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  hint: const Text('Выберите продукт', style: TextStyle(fontSize: 13)),
                  value: selectedId,
                  items: allIngredients.map<DropdownMenuItem<int>>((ing) {
                    return DropdownMenuItem<int>(
                      value: ing['id'],
                      child: Text('${ing['name']} (${ing['unit']})', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setS(() {
                      selectedId = val;
                      final ing = allIngredients.firstWhere((i) => i['id'] == val);
                      selectedName = ing['name'];
                      selectedUnit = ing['unit'];
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Количество (${selectedUnit ?? ''})',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              TextButton(
                onPressed: () {
                  if (selectedId == null || qtyController.text.isEmpty) return;
                  setState(() {
                    selectedIngredients.add({
                      'ingredient_id': selectedId,
                      'name': selectedName,
                      'unit': selectedUnit,
                      'quantity': double.tryParse(qtyController.text) ?? 0,
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Добавить'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название'), backgroundColor: Colors.red),
      );
      return;
    }
    if (selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы один ингредиент'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);
    final user = await ApiService.getUser();
    final result = await ApiService.addRecipe({
      'name': nameController.text,
      'meal_type': mealType,
      'cook_time_minutes': cookTime,
      'description': descController.text,
      'user_id': user?['id'] ?? 0,
      'ingredients': selectedIngredients,
    });

    setState(() => isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Рецепт сохранён!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сохранения'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text('Новый рецепт', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _save,
            child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Название
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Название', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Например: Омлет с сыром',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Тип приёма пищи
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Приём пищи', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: mealTypes.entries.map((e) {
                    final selected = mealType == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => mealType = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF2196F3) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? const Color(0xFF2196F3) : Colors.grey.shade200),
                        ),
                        child: Text(e.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white : Colors.grey,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Время приготовления
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Время приготовления', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [10, 20, 30, 40, 60].map((t) {
                    final selected = cookTime == t;
                    return GestureDetector(
                      onTap: () => setState(() => cookTime = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF2196F3) : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? const Color(0xFF2196F3) : Colors.grey.shade200),
                        ),
                        child: Text('$t мин',
                            style: TextStyle(
                              fontSize: 12,
                              color: selected ? Colors.white : Colors.grey,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Ингредиенты
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ингредиенты', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    GestureDetector(
                      onTap: _addIngredient,
                      child: const Text('+ Добавить',
                          style: TextStyle(fontSize: 12, color: Color(0xFF2196F3))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (selectedIngredients.isEmpty)
                  const Text('Нет ингредиентов', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ...selectedIngredients.asMap().entries.map((e) {
                  final i = e.key;
                  final ing = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${ing['name']}',
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Text('${ing['quantity']} ${ing['unit']}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => setState(() => selectedIngredients.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Описание
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Описание приготовления',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Пошаговое описание...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('Сохранить рецепт',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}