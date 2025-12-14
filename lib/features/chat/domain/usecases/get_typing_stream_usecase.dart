import '../repositories/chat_repository.dart';

class GetTypingStreamUseCase {
  final ChatRepository repo;
  GetTypingStreamUseCase(this.repo);
  Stream<bool> call(String roomId) => repo.getTypingStream(roomId);
}
