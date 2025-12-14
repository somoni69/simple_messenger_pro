import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager/auth_provider.dart';
import '../widgets/auth_field.dart';
import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Вызываем метод из провайдера
      await context.read<AuthProvider>().signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      
      // Если есть ошибка, показываем SnackBar (в реальном проекте можно сделать красивее)
      if (mounted && context.read<AuthProvider>().errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  "С возвращением!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                
                // Поля ввода
                AuthField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  validator: (val) => val!.isEmpty ? "Введите Email" : null,
                ),
                AuthField(
                  controller: _passwordController,
                  label: "Пароль",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) => val!.isEmpty ? "Введите пароль" : null,
                ),

                const SizedBox(height: 20),

                // Кнопка Входа
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Войти", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),

                // Переход на регистрацию
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text("Нет аккаунта? Зарегистрироваться"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}