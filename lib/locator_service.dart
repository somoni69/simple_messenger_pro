import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/upload_avatar_usecase.dart'; // Новый импорт
import 'features/auth/presentation/manager/auth_provider.dart';
import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/domain/usecases/get_chat_room_id_usecase.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/send_image_message_usecase.dart'; // +
import 'features/chat/domain/usecases/delete_message_usecase.dart'; // +
import 'features/chat/domain/usecases/send_typing_usecase.dart'; // +
import 'features/chat/domain/usecases/get_typing_stream_usecase.dart'; // +
import 'features/chat/domain/usecases/mark_messages_as_read_usecase.dart'; // +
import 'features/chat/presentation/manager/chat_provider.dart';
// Imports...
import 'features/users/data/datasources/users_remote_data_source.dart';
import 'features/users/data/repositories/users_repository_impl.dart';
import 'features/users/domain/repositories/users_repository.dart';
import 'features/users/domain/usecases/get_all_users_usecase.dart';
import 'features/users/presentation/manager/users_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  sl.registerFactory(
    () => AuthProvider(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      uploadAvatarUseCase: sl(), // Новый UseCase
    ),
  );

  // 2. UseCases (Domain Logic)
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl())); // Новый UseCase

  // 3. Repository (Domain Interface -> Data Implementation)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // 4. Data Sources (Data Logic)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  //! Features - Chat
  // 1. Provider
  sl.registerFactory(
    () => ChatProvider(
      getMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      getChatRoomIdUseCase: sl(), // <-- Добавили
      sendImageMessageUseCase: sl(), // +
      deleteMessageUseCase: sl(), // +
      sendTypingUseCase: sl(), // +
      getTypingStreamUseCase: sl(), // +
      markMessagesAsReadUseCase: sl(), // +
    ),
  );

  // 2. UseCases
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetChatRoomIdUseCase(sl())); // <-- Добавили
  sl.registerLazySingleton(() => SendImageMessageUseCase(sl())); // +
  sl.registerLazySingleton(() => DeleteMessageUseCase(sl())); // +
  sl.registerLazySingleton(() => SendTypingUseCase(sl())); // +
  sl.registerLazySingleton(() => GetTypingStreamUseCase(sl())); // +
  sl.registerLazySingleton(() => MarkMessagesAsReadUseCase(sl())); // +

  // 3. Repository
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // 4. Data Source
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );

  //! Features - Users
  sl.registerFactory(() => UsersProvider(sl()));
  sl.registerLazySingleton(() => GetAllUsersUsecase(sl()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(sl()));
  sl.registerLazySingleton<UsersRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );

  //! External
  // Клиент Supabase уже инициализирован в main.dart, здесь мы просто достаем инстанс
  final supabase = Supabase.instance.client;
  sl.registerLazySingleton(() => supabase);
}
