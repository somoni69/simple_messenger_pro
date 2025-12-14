import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.content,
    required super.senderId,
    required super.username,
    required super.createdAt,
    required super.isMine,
    required super.isImage, // +
    super.imageUrl,
    required super.isRead, // +
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String myUserId) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      senderId: json['profile_id'],
      username: json['username'] ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      isMine: json['profile_id'] == myUserId,
      isImage: json['type'] == 'image',
      imageUrl: json['image_url'],
      isRead: json['is_read'] ?? false, // В fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {'content': content, 'profile_id': senderId, 'username': username};
  }
}
