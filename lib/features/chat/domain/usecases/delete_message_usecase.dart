import '../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<void> call(String messageId) {
    return repository.deleteMessage(messageId);
  }
}
