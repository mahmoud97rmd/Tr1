import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          // Replace with actual backend API URL
          baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://192.168.1.100:10000'),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<Map<String, dynamic>> getStatus() async {
    final response = await _dio.get('/api/status');
    return response.data;
  }

  Future<void> toggleEngine() async {
    await _dio.post('/api/engine/toggle');
  }

  Future<void> toggleLiveConn() async {
    await _dio.post('/api/engine/live_conn');
  }

  Future<void> closeAllPositions() async {
    await _dio.post('/api/positions/close_all');
  }
  Future<void> updateConfig(Map<String, dynamic> config) async {
    await _dio.put('/api/config', data: config);
  }

  Future<void> startBacktest(int days) async {
    await _dio.post('/api/backtest/start', data: {'days': days});
  }

  Future<Map<String, dynamic>> getBacktestStatus() async {
    final response = await _dio.get('/api/backtest/status');
    return response.data;
  }
}
