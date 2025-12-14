import 'dart:io'; // Для File
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      return await remoteDataSource.signIn(email, password);
    } on ServerException catch (e) {
      throw ServerFailure(e.message); // Превращаем Exception в Failure
    }
  }

  @override
  Future<UserEntity> signUp(
    String email,
    String password,
    String username,
  ) async {
    try {
      return await remoteDataSource.signUp(email, password, username);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await remoteDataSource.getCurrentUser();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> uploadAvatar(File imageFile) async {
    try {
      return await remoteDataSource.uploadAvatar(imageFile);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
