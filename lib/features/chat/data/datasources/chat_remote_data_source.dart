import 'dart:io'; // +
import 'dart:async';
import 'package:flutter/foundation.dart'; // для compute
import 'package:flutter/material.dart'; // для debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<MessageModel>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String content);
  Future<String> getChatRoomId(String otherUserId);
  Future<void> sendImageMessage(String roomId, File imageFile); // +
  Future<void> deleteMessage(String messageId); // +
  Future<void> sendTyping(String roomId); // Отправить сигнал
  Stream<bool> getTypingStream(String roomId); // Слушать сигнал
  Future<void> markMessagesAsRead(String roomId); // Новый метод
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatRemoteDataSourceImpl(this.supabaseClient);

  // Кэшируем канал, чтобы не создавать его 100 раз
  RealtimeChannel? _channel;

  void _initChannel(String roomId) {
    // Создаем или получаем канал для конкретной комнаты
    _channel ??= supabaseClient.channel('room_$roomId');
  }

  @override
  Stream<List<MessageModel>> getMessages(String roomId) {
    final myUserId = supabaseClient.auth.currentUser!.id;

    return supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .limit(50) // <--- ДОБАВЬ ЭТО! Грузим только последние 50 сообщений
        .asyncMap((data) async {
          // Используем asyncMap вместо map
          // Вызываем compute. Flutter запустит parseMessages в другом ядре процессора.
          return await compute(parseMessages, {
            'data': data,
            'myUserId': myUserId,
          });
        });
  }

  @override
  Future<void> sendMessage(String roomId, String content) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw ServerException("Вы не авторизованы");
    final username = user.userMetadata?['username'] ?? 'User';

    await supabaseClient.from('messages').insert({
      'content': content,
      'profile_id': user.id,
      'username': username,
      'room_id': roomId, // <--- Указываем комнату
    });
  }

  @override
  Future<String> getChatRoomId(String otherUserId) async {
    try {
      // Вызываем нашу SQL функцию (RPC)
      final roomId = await supabaseClient.rpc(
        'create_or_get_chat',
        params: {
          'other_user_id': otherUserId, // Fixed variable name
        },
      );
      return roomId as String;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendImageMessage(String roomId, File imageFile) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException("Не авторизован");

      // 1. Загружаем картинку
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$roomId/$fileName'; // Храним в папке комнаты

      await supabaseClient.storage
          .from('chat_images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = supabaseClient.storage
          .from('chat_images')
          .getPublicUrl(path);

      // 2. Пишем сообщение в БД
      await supabaseClient.from('messages').insert({
        'profile_id': user.id,
        'room_id': roomId,
        'username': user.userMetadata?['username'] ?? 'User',
        'content': 'Фото', // Текст-заглушка для пуш-уведомлений или списка
        'type': 'image', // Указываем тип
        'image_url': imageUrl, // Ссылка
      });
    } catch (e) {
      throw ServerException("Ошибка отправки фото: $e");
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    // Мы не используем try-catch здесь, пусть ошибка летит в Repository
    // Важно: .match({'id': messageId}) или .eq('id', messageId)
    await supabaseClient.from('messages').delete().eq('id', messageId);
  }

  @override
  Future<void> sendTyping(String roomId) async {
    _initChannel(roomId);

    // Подписываемся, если еще не подписаны (нужно для отправки)
    // Но так как subscribe асинхронный, мы просто шлем, Supabase сам разберется
    _channel!.subscribe();

    // Шлем событие 'typing'
    await _channel!.sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': supabaseClient.auth.currentUser!.id},
    );
  }

  @override
  Stream<bool> getTypingStream(String roomId) {
    _initChannel(roomId);

    // We need to create a StreamController to transform the broadcast events
    final streamController = StreamController<bool>();

    // Listen to broadcast events
    _channel!.onBroadcast(
      event: 'typing',
      callback: (payload) {
        // Если пришло событие от ДРУГОГО юзера
        final senderId = payload['user_id'];
        final myId = supabaseClient.auth.currentUser!.id;
        streamController.add(
          senderId != myId,
        ); // Вернем true, если пишет кто-то другой
      },
    );

    // Subscribe to the channel
    _channel!.subscribe();

    return streamController.stream;
  }

  @override
  Future<void> markMessagesAsRead(String roomId) async {
    try {
      await supabaseClient.rpc(
        'mark_messages_read',
        params: {'room_id_param': roomId},
      );
    } catch (e) {
      // Ошибки тут не критичны, можно просто логировать
      debugPrint("Ошибка markRead: $e");
    }
  }
}

// Эта функция будет работать в другом потоке
List<MessageModel> parseMessages(Map<String, dynamic> data) {
  final List<dynamic> list = data['data'];
  final String myUserId = data['myUserId'];

  return list.map((json) => MessageModel.fromJson(json, myUserId)).toList();
}
