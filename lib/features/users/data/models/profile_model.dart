import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.username,
    required super.email,
    required super.avatarUrl,
    
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  } 
}   