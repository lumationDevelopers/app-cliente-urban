import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatSocketBloc {
  final _chatSocketController = BehaviorSubject();

  Function(dynamic) get modifySocket => _chatSocketController.sink.add;

  Stream get chatSocketStream => _chatSocketController.stream;

  get socket => _chatSocketController.value;

  dispose() {
    _chatSocketController?.close();
  }
}