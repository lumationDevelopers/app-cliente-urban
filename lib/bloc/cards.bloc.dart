import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CardsBloc {
  final _cardsController = BehaviorSubject<List<dynamic>>();

  Function(List<dynamic>) get modifyCards => _cardsController.sink.add;

  Stream<List<dynamic>> get cardsStream => _cardsController.stream;

  List<dynamic> get cards => _cardsController.value;

  dispose() {
    _cardsController?.close();
  }
}