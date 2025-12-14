import 'dart:io';
import '../repositories/chat_repository.dart';

class SendImageMessageUseCase {
  final ChatRepository repository;

  SendImageMessageUseCase(this.repository);

  // Принимаем файл и roomId
  Future<void> call(String roomId, File imageFile) {
    return repository.sendImageMessage(roomId, imageFile);
  }
}