import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  // Просто прокидываем параметры
  @override
  Stream<List<MessageEntity>> getMessages(String roomId) {
    return remoteDataSource.getMessages(roomId);
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    try {
      await remoteDataSource.sendMessage(roomId, content);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<String> getChatRoomId(String otherUserId) async {
    try {
      return await remoteDataSource.getChatRoomId(otherUserId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> sendImageMessage(String roomId, File imageFile) async {
    try {
      await remoteDataSource.sendImageMessage(roomId, imageFile);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await remoteDataSource.deleteMessage(messageId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendTyping(String roomId) async {
    await remoteDataSource.sendTyping(roomId);
  }

  @override
  Stream<bool> getTypingStream(String roomId) {
    return remoteDataSource.getTypingStream(roomId);
  }

  @override
  Future<void> markMessagesAsRead(String roomId) async {
    await remoteDataSource.markMessagesAsRead(roomId);
  }
}
