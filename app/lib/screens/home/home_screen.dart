import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../menu/menu_screen.dart';
import '../shopping/shopping_screen.dart';
import '../favorites/favorites_screen.dart';
import '../auth/register_screen.dart';
import '../recipe/add_recipe_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  int persons = 2;
  double budget = 5000;
  String preference = 'Без ограничений';
  bool isLoading = false;
  Map? currentUser;

  final List<double> budgetOptions = [3000, 5000, 8000, 10000];
  final List<String> preferences = ['Без ограничений', 'Вегетарианское', 'Без глютена'];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getUser();
    setState(() => currentUser = user);
  }

  Future<void> _generateMenu() async {
    if (currentUser == null) return;
    setState(() => isLoading = true);
    try {
      final result = await ApiService.generateMenu(
        currentUser!['id'],
        persons,
        budget,
      );
      if (!mounted) return;
      if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error']), backgroundColor: Colors.red),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuScreen(menu: result)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка подключения'), backgroundColor: Colors.red),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(),
          const Center(child: Text('Меню')),
          ShoppingScreen(menuId: 0),
          FavoritesScreen(userId: currentUser?['id'] ?? 0),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        children: [
          // Шапка
          Container(
            color: const Color(0xFF2196F3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                const Text('Планировщик меню',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: _logout,
                  child: const Icon(Icons.logout, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddRecipeScreen())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Добавить свой рецепт'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('Привет, ${currentUser!['name']}! 👋',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),

                  const Text('Настройте параметры и получите меню на неделю',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),

                  // Карточка
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Количество персон
                        _buildSectionTitle(Icons.people_outline, 'Количество персон'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildCountButton(Icons.remove, () {
                              if (persons > 1) setState(() => persons--);
                            }),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text('$persons',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2196F3))),
                                ),
                              ),
                            ),
                            _buildCountButton(Icons.add, () {
                              if (persons < 20) setState(() => persons++);
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Бюджет
                        _buildSectionTitle(Icons.monetization_on_outlined, 'Бюджет на неделю'),
                        const SizedBox(height: 10),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Text('${budget.toStringAsFixed(0)} ₽',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: budgetOptions.map((b) {
                            final selected = budget == b;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => budget = b),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xFF2196F3) : const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected ? const Color(0xFF2196F3) : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${b.toStringAsFixed(0)} ₽',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: selected ? Colors.white : Colors.grey,
                                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Предпочтения
                        _buildSectionTitle(Icons.eco_outlined, 'Предпочтения'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: preferences.map((p) {
                            final selected = preference == p;
                            return GestureDetector(
                              onTap: () => setState(() => preference = p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? Colors.green : Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(p,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selected ? Colors.green : Colors.grey,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Кнопка генерации
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : _generateMenu,
                            icon: isLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Icon(Icons.auto_awesome, color: Colors.white),
                            label: Text(
                              isLoading ? 'Генерируем...' : 'Сгенерировать меню',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCountButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Главная'},
      {'icon': Icons.date_range_outlined, 'label': 'Меню'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Покупки'},
      {'icon': Icons.favorite_outline, 'label': 'Избранное'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = _currentTab == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[i]['icon'] as IconData,
                          size: 22,
                          color: selected ? const Color(0xFF2196F3) : Colors.grey),
                      const SizedBox(height: 2),
                      Text(items[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? const Color(0xFF2196F3) : Colors.grey,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}