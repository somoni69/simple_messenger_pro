import '../repositories/chat_repository.dart';

class GetChatRoomIdUseCase {
  final ChatRepository repository;
  GetChatRoomIdUseCase(this.repository);

  Future<String> call(String otherUserId) {
    return repository.getChatRoomId(otherUserId);
  }
}
