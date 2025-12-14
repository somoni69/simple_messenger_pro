import '../entities/profile_entity.dart';

abstract class UsersRepository {
  Future<List<ProfileEntity>> getAllUsers();
}