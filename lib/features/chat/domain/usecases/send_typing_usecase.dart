import '../repositories/chat_repository.dart';

class SendTypingUseCase {
  final ChatRepository repo;
  SendTypingUseCase(this.repo);
  Future<void> call(String roomId) => repo.sendTyping(roomId);
}
