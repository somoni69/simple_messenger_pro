import 'dart:io';
import '../repositories/auth_repository.dart';

class UploadAvatarUseCase {
  final AuthRepository repository;
  UploadAvatarUseCase(this.repository);

  Future<String> call(File image) {
    return repository.uploadAvatar(image);
  }
}
