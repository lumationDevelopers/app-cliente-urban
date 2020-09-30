import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AddressBloc {
  final _addressController = BehaviorSubject<List<dynamic>>();

  Function(List<dynamic>) get modifyAddresses => _addressController.sink.add;

  Stream<List<dynamic>> get addressStream => _addressController.stream;

  List<dynamic> get addresses => _addressController.value;

  dispose() {
    _addressController?.close();
  }
}