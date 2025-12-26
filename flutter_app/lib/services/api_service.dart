import 'package:dio/dio.dart';
import '../models/task.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:8000',
        _dio = Dio() {
    _dio.options.baseUrl = baseUrl ?? 'http://localhost:8000';
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
    _dio.options.sendTimeout = const Duration(seconds: 20);
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
  }

  Future<Map<String, dynamic>> getTasks({
    int page = 1,
    int pageSize = 10,
    String? category,
    String? priority,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/tasks',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> getTask(int id) async {
    try {
      final response = await _dio.get('/api/tasks/$id');
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> createTask(TaskCreate task) async {
    try {
      final response = await _dio.post(
        '/api/tasks',
        data: task.toJson(),
      );
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Task> updateTask(int id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.patch(
        '/api/tasks/$id',
        data: updates,
      );
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio.delete('/api/tasks/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['detail'] ?? 'Unknown error';
      return 'Error $statusCode: $message';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out';
    } else {
      return 'Network error occurred';
    }
  }
}
