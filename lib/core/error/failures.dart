import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Произошла ошибка сервера']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка кэша']);
}