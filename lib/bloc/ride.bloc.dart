import 'dart:async';
import 'package:rxdart/rxdart.dart';


class RideBloc {

  final _rideController = BehaviorSubject<Map<dynamic, dynamic>>();

  Function(Map<dynamic, dynamic>) get modifyRideData => _rideController.sink.add;

  Stream<Map<dynamic,dynamic>> get rideStream => _rideController.stream;

  Map<dynamic, dynamic> get rideInfo => _rideController.value;

  dispose() {
    _rideController?.close();
  }
}
