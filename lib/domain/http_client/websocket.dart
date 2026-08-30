import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  String? url = dotenv.env['WS_URL'];
  WebSocketChannel? _channel;

  WebSocketClient({this.url = 'wss://echo.websocket.org'});

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url!));
    debugPrint('Connected to WebSocket at: $url');
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(message);
      debugPrint('Sent: $message');
    } else {
      debugPrint('WebSocket not connected!');
    }
  }

  Stream<String> get messages {
    if (_channel != null) {
      return _channel!.stream.map((message) => message.toString());
    } else {
      throw Exception('WebSocket not connected!');
    }
  }

  void close() {
    _channel?.sink.close();
    debugPrint('WebSocket connection closed');
  }
}
