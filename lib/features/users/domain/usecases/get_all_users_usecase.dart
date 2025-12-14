import '../entities/profile_entity.dart';
import '../repositories/users_repository.dart';

class GetAllUsersUsecase {
  final UsersRepository repository;

  GetAllUsersUsecase(this.repository);

  Future<List<ProfileEntity>> call() {
    return repository.getAllUsers();
  }
}
