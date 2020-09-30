import 'dart:async';
import 'package:rxdart/rxdart.dart';


class RideStatusBloc {

  final _rideStatusController = BehaviorSubject<String>();

  Function(String) get modifyRideStatus => _rideStatusController.sink.add;

  Stream<String> get rideStatusStream => _rideStatusController.stream;

  String get rideStatus => _rideStatusController.value;

  dispose() {
    _rideStatusController?.close();
  }
}
