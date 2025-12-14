import 'dart:io';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages(String roomId); // + roomId
  Future<void> sendMessage(String roomId, String content); // + roomId
  Future<String> getChatRoomId(String otherUserId); // + Новый метод
  Future<void> sendImageMessage(String roomId, File imageFile);
  Future<void> deleteMessage(String messageId);
  Future<void> sendTyping(String roomId);
  Stream<bool> getTypingStream(String roomId);
  Future<void> markMessagesAsRead(String roomId); // Новый метод
}
