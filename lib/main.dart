import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'locator_service.dart' as di;
import 'features/auth/presentation/manager/auth_provider.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/chat/presentation/manager/chat_provider.dart';
import 'features/users/presentation/pages/users_page.dart';
import 'features/users/presentation/manager/users_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Оборачиваем MaterialApp в MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => di.sl<AuthProvider>()..checkAuth(),
        ),
        // Добавляем ChatProvider
        ChangeNotifierProvider(create: (_) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UsersProvider>()),
      ],
      child: MaterialApp(
        title: 'Messenger Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        // Временная заглушка, пока не сделаем UI
        home: const AuthWrapper(),
      ),
    );
  }
}

// Временный виджет для проверки состояния
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.user != null) {
      return const UsersPage(); // <-- Теперь идем в список юзеров, а не в общий чат
    }

    // Используем настоящую страницу входа вместо временного экрана
    return const SignInPage();
  }
}
