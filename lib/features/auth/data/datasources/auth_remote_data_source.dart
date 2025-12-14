import 'dart:io'; // <--- Не забудь
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<String> uploadAvatar(File imageFile); // Новый метод
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw ServerException('Пользователь не найден после входа');
      }
      return UserModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'username': username}, // Сохраняем имя в metadata
      );

      if (response.user == null) {
        throw ServerException('Ошибка регистрации');
      }
      return UserModel.fromSupabase(response.user!);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabase(user);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final userId = supabaseClient.auth.currentUser!.id;
      final path = '/$userId/avatar.jpg';

      // 1. Загружаем файл (перезаписываем старый)
      await supabaseClient.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Получаем ссылку с timestamp (чтобы сбросить кэш телефона)
      final imageUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(path);
      final finalUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // 3. Обновляем таблицу profiles (для других юзеров)
      await supabaseClient
          .from('profiles')
          .update({'avatar_url': finalUrl})
          .eq('id', userId);

      // 4. ВАЖНО: Обновляем метаданные auth юзера (для себя, чтобы UI обновился сразу)
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {'avatar_url': finalUrl}),
      );

      return finalUrl;
    } catch (e) {
      throw ServerException("Ошибка загрузки фото: $e");
    }
  }
}
