import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class FavoritesScreen extends StatefulWidget {
  final int userId;
  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List menus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId > 0) _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await ApiService.getFavorites(widget.userId);
    setState(() { menus = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Избранное', style: TextStyle(fontSize: 16)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menus.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Нет сохранённых меню', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menus.length,
        itemBuilder: (_, i) {
          final m = menus[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(m['favorite_name'] ?? 'Меню',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text(
                '${m['persons_count']} чел. · ${double.tryParse(m['total_cost'].toString())?.toStringAsFixed(0)} ₽',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}