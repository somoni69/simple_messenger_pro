import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String username;
  final DateTime createdAt;
  final bool isMine;

  final bool isImage;
  final String? imageUrl;
  final bool isRead; // <--- Новое поле

  const MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.username,
    required this.createdAt,
    this.isMine = false,
    this.isImage = false, // По умолчанию текст
    this.imageUrl,
    this.isRead = false, // Default
  });

  @override
  List<Object?> get props => [
    id,
    content,
    senderId,
    createdAt,
    isMine,
    isImage,
    imageUrl,
    isRead,
  ];
}
