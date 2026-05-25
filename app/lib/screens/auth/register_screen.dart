import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLogin = false;
  bool isLoading = false;
  bool obscurePassword = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _submit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    setState(() => isLoading = true);
    try {
      Map result;
      if (isLogin) {
        result = await ApiService.login(emailController.text, passwordController.text);
      } else {
        if (nameController.text.isEmpty) {
          _showError('Введите имя');
          setState(() => isLoading = false);
          return;
        }
        result = await ApiService.register(nameController.text, emailController.text, passwordController.text);
      }

      if (result.containsKey('error')) {
        _showError(result['error']);
      } else {
        await ApiService.saveToken(result['token']);
        await ApiService.saveUser(result['user']);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      _showError('Ошибка подключения к серверу');
    }
    setState(() => isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Логотип
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.calendar_month, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('Планировщик меню',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Иркутск · питание на неделю',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 32),

                // Карточка формы
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16)],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isLogin ? 'Вход' : 'Регистрация',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Имя (только для регистрации)
                      if (!isLogin) ...[
                        _buildLabel('Имя'),
                        _buildField(nameController, 'Иван Иванов', Icons.person_outline),
                        const SizedBox(height: 14),
                      ],

                      _buildLabel('Email'),
                      _buildField(emailController, 'example@mail.ru', Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 14),

                      _buildLabel('Пароль'),
                      _buildPasswordField(),
                      const SizedBox(height: 24),

                      // Кнопка
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : Text(isLogin ? 'Войти' : 'Зарегистрироваться',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Переключение
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() => isLogin = !isLogin),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              children: [
                                TextSpan(text: isLogin ? 'Нет аккаунта? ' : 'Уже есть аккаунт? '),
                                TextSpan(
                                  text: isLogin ? 'Зарегистрироваться' : 'Войти',
                                  style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: 'Минимум 8 символов',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}