import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../utils/logger.dart';
import 'storage_service.dart';

class NetworkService {
  final Dio _dio;

  NetworkService({FlutterSecureStorage? secureStorage})
      : _dio = Dio(
          BaseOptions(
            baseUrl: Environment.current.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    final storage = secureStorage ?? const FlutterSecureStorage();
    _initializeInterceptors();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: StorageService.keyJwtToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Dio get client => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          AppLogger.debug(
              'HTTP Request: [${options.method}] -> ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
              'HTTP Response: [${response.statusCode}] <- ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          AppLogger.error(
            'HTTP Failure: [${error.response?.statusCode}] -> ${error.requestOptions.path}',
            error,
            error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }
}
