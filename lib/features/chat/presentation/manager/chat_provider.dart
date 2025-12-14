import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/get_chat_room_id_usecase.dart';
import '../../domain/usecases/send_image_message_usecase.dart'; // +
import '../../domain/usecases/delete_message_usecase.dart'; // +
import '../../domain/usecases/send_typing_usecase.dart';
import '../../domain/usecases/get_typing_stream_usecase.dart';
import '../../domain/usecases/mark_messages_as_read_usecase.dart'; // +

class ChatProvider extends ChangeNotifier {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final GetChatRoomIdUseCase getChatRoomIdUseCase;
  final SendImageMessageUseCase sendImageMessageUseCase; // +
  final DeleteMessageUseCase deleteMessageUseCase; // +
  final SendTypingUseCase sendTypingUseCase;
  final GetTypingStreamUseCase getTypingStreamUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase; // +

  ChatProvider({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.getChatRoomIdUseCase,
    required this.sendImageMessageUseCase, // +
    required this.deleteMessageUseCase, // +
    required this.sendTypingUseCase,
    required this.getTypingStreamUseCase,
    required this.markMessagesAsReadUseCase, // +
  });

  bool _isOtherUserTyping = false;
  bool get isOtherUserTyping => _isOtherUserTyping;

  Timer? _typingTimer;
  StreamSubscription? _typingSubscription;

  // Инициализация прослушки (вызовем в initState UI)
  void initTypingListener(String roomId) {
    _typingSubscription?.cancel();

    _typingSubscription = getTypingStreamUseCase(roomId).listen((isTyping) {
      if (isTyping) {
        _isOtherUserTyping = true;
        notifyListeners();

        // Сбрасываем таймер, если он был
        _typingTimer?.cancel();

        // Через 3 секунды тишины убираем надпись
        _typingTimer = Timer(const Duration(seconds: 3), () {
          _isOtherUserTyping = false;
          notifyListeners();
        });
      }
    });
  }

  // Отправка сигнала (вызовем при вводе текста)
  void sendTyping(String roomId) {
    // Чтобы не спамить сервером, можно добавить throttle (ограничение),
    // но пока будем слать просто при каждом изменении текста.
    sendTypingUseCase(roomId);
  }

  Future<String?> getRoomId(String otherUserId) async {
    try {
      return await getChatRoomIdUseCase(otherUserId);
    } catch (e) {
      debugPrint("Ошибка получения комнаты: $e");
      return null;
    }
  }

  // Метод отправки теперь требует roomId
  Future<void> sendMessage(String roomId, String content) async {
    if (content.trim().isEmpty) return;
    try {
      await sendMessageUseCase(roomId, content);
    } catch (e) {
      debugPrint("Ошибка отправки: $e");
    }
  }

  Future<void> sendImage(String roomId, File imageFile) async {
    try {
      await sendImageMessageUseCase(roomId, imageFile);
      // Стрим сам обновится
    } catch (e) {
      debugPrint("Ошибка отправки фото: $e");
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await deleteMessageUseCase(messageId);
      // Ничего обновлять не надо, Stream сам пришлет новый список без этого сообщения
    } catch (e) {
      debugPrint("Не удалось удалить сообщение: $e");
    }
  }

  // Метод для получения стрима (вызываем прямо в UI)
  Stream<List<MessageEntity>> messagesStream(String roomId) {
    // ХАК: Как только мы подписываемся на стрим, значит мы открыли чат.
    // Помечаем сообщения прочитанными.
    markMessagesAsRead(roomId);

    return getMessagesUseCase(roomId).map((messages) {
      // Если пришло новое сообщение и мы всё еще слушаем стрим — помечаем и его
      if (messages.isNotEmpty &&
          !messages.first.isMine &&
          !messages.first.isRead) {
        markMessagesAsRead(roomId);
      }
      return messages;
    });
  }

  Future<void> markMessagesAsRead(String roomId) async {
    await markMessagesAsReadUseCase(roomId);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _typingSubscription?.cancel();
    super.dispose();
  }
}
