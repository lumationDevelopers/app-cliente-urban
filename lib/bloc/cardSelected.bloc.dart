import 'dart:async';
import 'package:rxdart/rxdart.dart';


class CardSelectedBloc {

  final _cardSelectedController = BehaviorSubject<Map<dynamic, dynamic>>();

  Function(Map<dynamic, dynamic>) get modifyCardSelected => _cardSelectedController.sink.add;

  Stream<Map<dynamic,dynamic>> get cardSelectedStream => _cardSelectedController.stream;

  Map<dynamic, dynamic> get card => _cardSelectedController.value;

  dispose() {
    _cardSelectedController?.close();
  }
}
