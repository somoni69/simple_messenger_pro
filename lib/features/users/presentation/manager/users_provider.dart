import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_all_users_usecase.dart';

class UsersProvider extends ChangeNotifier {
  final GetAllUsersUsecase getAllUsersUsecase;

  UsersProvider(this.getAllUsersUsecase);

  List<ProfileEntity> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProfileEntity> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await getAllUsersUsecase();
    } catch (e) {
      _errorMessage = "Не удалось загрузить пользователей";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
