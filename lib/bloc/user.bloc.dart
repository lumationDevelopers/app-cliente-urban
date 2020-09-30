import 'dart:async';
import 'package:rxdart/rxdart.dart';


class UserBloc {

  final _userController = BehaviorSubject<Map<dynamic, dynamic>>();

  Function(Map<dynamic, dynamic>) get modifyUserData => _userController.sink.add;

  Stream<Map<dynamic,dynamic>> get userStream => _userController.stream;

  Map<dynamic, dynamic> get userInfo => _userController.value;

  dispose() {
    _userController?.close();
  }
}
