import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<ProfileModel>> getAllUsers();
}

class UserRemoteDataSourceImpl implements UsersRemoteDataSource {
  final SupabaseClient supabaseClient;

  UserRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ProfileModel>> getAllUsers() async {
    try {
      final currentUserId = supabaseClient.auth.currentUser!.id;

      final data = await supabaseClient
          .from('profiles')
          .select()
          .neq('id', currentUserId);

      return (data as List).map((json) => ProfileModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
