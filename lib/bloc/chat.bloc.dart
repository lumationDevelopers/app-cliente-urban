import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatBloc {
  final _chatController = BehaviorSubject<List<dynamic>>();

  Function(List<dynamic>) get modifyMessages => _chatController.sink.add;

  Stream<List<dynamic>> get chatStream => _chatController.stream;

  List<dynamic> get messages => _chatController.value;

  dispose() {
    _chatController?.close();
  }
}