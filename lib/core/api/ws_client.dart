import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wsClientProvider = Provider((ref) => WsClient());

class WsClient {
  WebSocketChannel? _channel;
  
  // You would replace this with your actual Render/VPS websocket URL
  final String _wsUrl = const String.fromEnvironment('WS_URL', defaultValue: 'ws://192.168.1.100:10000/ws/stream');

  Stream<dynamic>? get stream => _channel?.stream.map((event) => jsonDecode(event));

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
