import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wsClientProvider = Provider((ref) => WsClient());

class WsClient {
  WebSocketChannel? _channel;
  
  // You would replace this with your actual Render/VPS websocket URL
  final String _wsUrl = const String.fromEnvironment('WS_URL', defaultValue: 'ws://192.168.1.100:10000/ws/stream');

  Stream<dynamic>? _broadcastStream;

  Stream<dynamic>? get stream => _broadcastStream;

  void connect() {
    if (_channel != null) return;
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
    _broadcastStream = _channel!.stream.asBroadcastStream().map((event) => jsonDecode(event));
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
