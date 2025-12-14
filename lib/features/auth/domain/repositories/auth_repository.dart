import '../entities/user_entity.dart';
import 'dart:io'; // Для File

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);

  Future<UserEntity> signUp(String email, String password, String username);

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();

  Future<String> uploadAvatar(File imageFile); // Новый метод
}
