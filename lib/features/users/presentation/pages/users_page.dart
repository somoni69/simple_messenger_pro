import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Импорт
import '../../../auth/presentation/manager/auth_provider.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../manager/users_provider.dart';
import 'profile_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем список при входе
    Future.microtask(() => context.read<UsersProvider>().loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = context.watch<UsersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Чаты"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      body: usersProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : usersProvider.errorMessage != null
          ? Center(child: Text(usersProvider.errorMessage!))
          : ListView.separated(
              itemCount: usersProvider.users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = usersProvider.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    child: user.avatarUrl == null
                        ? Text(user.username[0].toUpperCase())
                        : ClipOval(
                            // Обрезаем картинку по кругу
                            child: CachedNetworkImage(
                              imageUrl: user.avatarUrl!,
                              width: 48, // 24 radius * 2
                              height: 48,
                              fit: BoxFit.cover,
                              // Если грузится — показываем крутилку
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                              // Если ошибка — иконку
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  onTap: () {
                    // МГНОВЕННЫЙ ПЕРЕХОД
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          otherUserId: user.id, // Передаем ID собеседника
                          otherUserName: user.username,
                          otherUserAvatar: user.avatarUrl,
                          // roomId не передаем, пусть чат сам его ищет
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
