import 'package:flutter/foundation.dart';

@immutable
abstract class Failure {
  final String message;
  final String? debugDetails;

  const Failure(this.message, [this.debugDetails]);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  final int? statusCode;
  const NetworkFailure(String message, {this.statusCode, String? debugDetails})
      : super(message, debugDetails);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.debugDetails]);
}

class AIFailure extends Failure {
  const AIFailure(super.message, [super.debugDetails]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.debugDetails]);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, [this.statusCode]);
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
}
