import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';
import '../manager/chat_provider.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId; // ID собеседника (обязательно)
  final String otherUserName;
  final String? otherUserAvatar;

  // roomId теперь не обязателен при входе!
  final String? existingRoomId;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.existingRoomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  DateTime? _lastTypingTime;

  // roomId может быть null сначала, потом загрузится
  String? _roomId;

  @override
  void initState() {
    super.initState();
    _roomId = widget.existingRoomId;

    // Если ID комнаты нет — загружаем его
    if (_roomId == null) {
      _loadRoomId();
    } else {
      _initFeatures();
    }
  }

  Future<void> _loadRoomId() async {
    // Получаем ID комнаты в фоне
    final roomId = await context.read<ChatProvider>().getRoomId(
      widget.otherUserId,
    );

    if (mounted && roomId != null) {
      setState(() {
        _roomId = roomId;
      });
      _initFeatures();
    }
  }

  void _initFeatures() {
    if (_roomId == null) return;
    // Включаем слушатель "печатает..."
    context.read<ChatProvider>().initTypingListener(_roomId!);
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty && _roomId != null) {
      // Проверяем _roomId
      context.read<ChatProvider>().sendMessage(_roomId!, text);
      _controller.clear();
    }
  }

  Future<void> _pickImage() async {
    if (_roomId == null) return; // Нельзя слать, пока комната не загрузилась
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null && mounted) {
      context.read<ChatProvider>().sendImage(_roomId!, File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: widget.otherUserAvatar == null
                  ? Text(
                      widget.otherUserName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    )
                  : ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.otherUserAvatar!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(Icons.person),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(fontSize: 16),
                ),

                // ✅ ОПТИМИЗАЦИЯ: Перерисовываем ТОЛЬКО текст "печатает..."
                Selector<ChatProvider, bool>(
                  selector: (_, provider) => provider.isOtherUserTyping,
                  builder: (context, isTyping, child) {
                    if (!isTyping)
                      return const SizedBox.shrink(); // Пустой виджет, если не пишет
                    return const Text(
                      "печатает...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _roomId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<MessageEntity>>(
                    // Стрим сам по себе эффективен, он не зависит от notifyListeners провайдера
                    stream: context.read<ChatProvider>().messagesStream(
                      _roomId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("Нет сообщений. Напиши первым!"),
                        );
                      }
                      final messages = snapshot.data!;
                      return ListView.builder(
                        // Добавляем ключи для оптимизации списка
                        key: const PageStorageKey('chat_list'),
                        itemCount: messages.length,
                        padding: const EdgeInsets.all(10),
                        // addAutomaticKeepAlives: true - по умолчанию, помогает держать ячейки живыми
                        itemBuilder: (context, index) {
                          // Передаем ValueKey, чтобы Flutter понимал, какой элемент удалился/добавился
                          return _MessageBubble(
                            key: ValueKey(messages[index].id),
                            message: messages[index],
                          );
                        },
                      );
                    },
                  ),
          ),
          // Поле ввода
          Opacity(
            opacity: _roomId == null ? 0.5 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _roomId == null ? null : _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: _roomId != null, // Блокируем ввод
                      decoration: const InputDecoration(
                        hintText: "Напиши сообщение...",
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        // Логика тайпинга (скопируй свою с DateTime)
                        if (val.isNotEmpty && _roomId != null) {
                          final now = DateTime.now();
                          // Если с прошлого раза прошло меньше 2 секунд — ничего не делаем
                          if (_lastTypingTime != null &&
                              now.difference(_lastTypingTime!) <
                                  const Duration(seconds: 2)) {
                            return;
                          }

                          // Иначе — шлем запрос и обновляем время
                          _lastTypingTime = now;
                          context.read<ChatProvider>().sendTyping(_roomId!);
                        }
                      },
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _roomId == null ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMine;

  _MessageBubble({super.key, required this.message}) : isMine = message.isMine;

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить сообщение?'),
          content: const Text('Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Получаем провайдер и вызываем удаление
                final provider = context.read<ChatProvider>();
                provider.deleteMessage(message.id);
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMine =
        message.isMine; // <--- Проверь, что это поле true для твоих сообщений

    return GestureDetector(
      onLongPress: () {
        if (isMine) {
          _showDeleteDialog(context);
        } else {
          // Для отладки: выведи в консоль, если нажатие работает, но это не твое сообщение
          debugPrint("Это не твое сообщение, удалять нельзя");
        }
      },
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMine
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMine && message.username.isNotEmpty) ...[
                Text(
                  message.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isMine
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (message.isImage && message.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: message.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ] else ...[
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMine
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormatter.formatMessageTime(message.createdAt),
                    style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                  // ПОКАЗЫВАЕМ ГАЛОЧКИ ТОЛЬКО ДЛЯ СВОИХ СООБЩЕНИЙ
                  if (isMine) ...[
                    const SizedBox(width: 4),
                    Icon(
                      // Если прочитано — двойная галочка, иначе — одна
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      // Если прочитано — цвет яркий (или белый/синий), иначе серый
                      color: message.isRead
                          ? (isMine ? Colors.white : Colors.blue)
                          : (isMine ? Colors.white60 : Colors.grey),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
