import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager/auth_provider.dart';
import '../widgets/auth_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthProvider>().signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _usernameController.text.trim(),
          );

      if (mounted) {
        final error = context.read<AuthProvider>().errorMessage;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        } else {
          // Если успешно, закрываем экран регистрации (возвращаемся на логин или попадаем в AuthWrapper)
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(), // Кнопка "Назад" появится автоматически
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Создать аккаунт",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                
                AuthField(
                  controller: _usernameController,
                  label: "Имя пользователя",
                  icon: Icons.person_outline,
                  validator: (val) => val!.isEmpty ? "Введите имя" : null,
                ),
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
                  validator: (val) => val!.length < 6 ? "Минимум 6 символов" : null,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Зарегистрироваться"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}