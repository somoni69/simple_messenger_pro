import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String roomId, String content) {
    return repository.sendMessage(roomId, content);
  }
}
