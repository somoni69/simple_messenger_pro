import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Импорт
import '../../../auth/presentation/manager/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Показываем индикатор загрузки (можно через SnackBar или состояние)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Загружаем фото...")));

      // Вызываем обновление
      await context.read<AuthProvider>().updateAvatar(_image!);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Аватар обновлен!")));
        setState(() {}); // Перерисовываем экран, чтобы подтянуть новую картинку
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await context.read<AuthProvider>().updateAvatar(_image!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Аватар успешно обновлен")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Ошибка: $e")));
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Получаем юзера напрямую из Supabase, так как мы обновили метаданные
    // Или через AuthProvider, если он хранит user entity
    final user = context.watch<AuthProvider>().user;

    // Пытаемся достать аватарку из Entity.
    // Если в Entity нет поля avatarUrl, можно временно брать из Supabase instance:
    final avatarUrl =
        Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'];

    return Scaffold(
      appBar: AppBar(title: const Text("Профиль")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage, // Нажатие на сам кружок тоже открывает галерею
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.purple[100],
                backgroundImage: avatarUrl != null
                    ? CachedNetworkImageProvider(
                        avatarUrl,
                      ) // <--- ТУРБО ЗАГРУЗКА
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.purple)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Поля пользователя
            if (user != null) ...[
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(user.email),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Имя пользователя"),
                subtitle: Text(user.username ?? ''),
              ),
            ],

            const SizedBox(height: 40),

            // Кнопка загрузки
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _pickImage, // <-- Подключаем функцию сюда
                child: const Text("Загрузить аватар"),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка выхода
            SizedBox(
              width: 200,
              child: OutlinedButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text("Выйти", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
