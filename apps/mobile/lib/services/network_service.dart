import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../utils/logger.dart';

class NetworkService {
  final Dio _dio;

  NetworkService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: Environment.current.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    _initializeInterceptors();
  }

  Dio get client => _dio;

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Authentication Interceptor Placeholder:
          // Read local secure JWT token and append to Headers.
          const mockJwtToken = "Bearer_Token_Placeholder";
          options.headers['Authorization'] = 'Bearer $mockJwtToken';
          
          AppLogger.debug('HTTP Request: [${options.method}] -> ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug('HTTP Response: [${response.statusCode}] <- ${response.requestOptions.path}');
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
