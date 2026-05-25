import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ShoppingScreen extends StatefulWidget {
  final int menuId;
  const ShoppingScreen({super.key, required this.menuId});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.menuId > 0) _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await ApiService.getShopping(widget.menuId);
    setState(() { items = data; isLoading = false; });
  }

  Future<void> _toggleBought(int id, bool current) async {
    await ApiService.setBought(id, !current);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menuId == 0) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: Text('Сначала сгенерируйте меню', style: TextStyle(color: Colors.grey))),
      );
    }

    final bought = items.where((i) => i['is_bought'] == 1).length;
    final total = items.fold(0.0, (s, i) => s + (double.tryParse(i['total_cost'].toString()) ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        title: const Text('Список покупок', style: TextStyle(fontSize: 16)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Прогресс
          Container(
            color: const Color(0xFFE3F2FD),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('Куплено: $bought / ${items.length}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: items.isEmpty ? 0 : bought / items.length,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.green,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${total.toStringAsFixed(0)} ₽',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2196F3))),
              ],
            ),
          ),

          // Список
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final isBought = item['is_bought'] == 1;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => _toggleBought(item['id'], isBought),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isBought ? Colors.green : Colors.transparent,
                          border: Border.all(color: isBought ? Colors.green : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isBought
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    ),
                    title: Text(item['name'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          decoration: isBought ? TextDecoration.lineThrough : null,
                          color: isBought ? Colors.grey : Colors.black,
                        )),
                    trailing: Text(
                      '${double.tryParse(item['quantity'].toString())?.toStringAsFixed(0)} ${item['unit']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}