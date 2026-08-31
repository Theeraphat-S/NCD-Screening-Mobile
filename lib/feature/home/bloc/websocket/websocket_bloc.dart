import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/http_client/websocket.dart';
import 'package:ncd_screening_mobile/locator.dart';

part 'websocket_event.dart';
part 'websocket_state.dart';

class WebsocketBloc extends Bloc<WebsocketEvent, WebsocketState> {
  final wsClient = locator<WebSocketClient>();
  final List<String> _messages = [];
  List<String> get messages => _messages;

  WebsocketBloc() : super(WebsocketInitial()) {
    on<InitialEvent>(_onInitial);
    on<SendEvent>(_onSend);

    add(const InitialEvent());
  }

  Future<void> _onInitial(
      InitialEvent event, Emitter<WebsocketState> emit) async {
    wsClient.connect();
    wsClient.messages.listen((message) {
      _messages.add(message);
      emit(WebsocketLoadMessage(_messages));
      debugPrint('Received: $message');
    });
  }

  Future<void> _onSend(SendEvent event, Emitter<WebsocketState> emit) async {
    wsClient.sendMessage(event.message);
    emit(WebsocketLoadMessage(_messages));
  }
}
