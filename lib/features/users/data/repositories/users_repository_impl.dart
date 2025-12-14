import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProfileEntity>> getAllUsers() async {
    try {
      return await remoteDataSource.getAllUsers();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
