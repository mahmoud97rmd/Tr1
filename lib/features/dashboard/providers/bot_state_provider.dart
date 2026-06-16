import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';

final botStateProvider = StateNotifierProvider<BotStateNotifier, Map<String, dynamic>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BotStateNotifier(apiClient);
});

class BotStateNotifier extends StateNotifier<Map<String, dynamic>> {
  final ApiClient _apiClient;
  Timer? _timer;

  BotStateNotifier(this._apiClient) : super({}) {
    fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchStatus());
  }

  Future<void> fetchStatus() async {
    try {
      final status = await _apiClient.getStatus();
      state = status;
    } catch (e) {
      state = {'error': e.toString()};
    }
  }

  Future<void> toggleEngine() async {
    await _apiClient.toggleEngine();
    await fetchStatus();
  }

  Future<void> toggleLiveConn() async {
    await _apiClient.toggleLiveConn();
    await fetchStatus();
  }

  Future<void> closeAllPositions() async {
    await _apiClient.closeAllPositions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
