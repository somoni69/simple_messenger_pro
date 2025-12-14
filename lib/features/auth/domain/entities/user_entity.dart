import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl; // Новое поле

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl, // Новый параметр
  });

  @override
  List<Object?> get props => [id, email, username, avatarUrl];
}
