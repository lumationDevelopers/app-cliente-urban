import 'dart:async';
import 'package:rxdart/rxdart.dart';


class AddCardOnRegisterBloc {

  final _addCardOnRegisterController = BehaviorSubject<Map<dynamic, dynamic>>();

  Function(Map<dynamic, dynamic>) get modifyCard => _addCardOnRegisterController.sink.add;

  Stream<Map<dynamic,dynamic>> get addCardOnRegisterStream => _addCardOnRegisterController.stream;

  Map<dynamic, dynamic> get card => _addCardOnRegisterController.value;

  dispose() {
    _addCardOnRegisterController?.close();
  }
}
