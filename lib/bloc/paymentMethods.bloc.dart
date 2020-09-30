import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PaymentMethodsBloc {
  final _paymentMethodsController = BehaviorSubject<List<dynamic>>();

  Function(List<dynamic>) get modifyPaymentMethods => _paymentMethodsController.sink.add;

  Stream<List<dynamic>> get paymentMethodStream => _paymentMethodsController.stream;

  List<dynamic> get paymentMethods => _paymentMethodsController.value;

  dispose() {
    _paymentMethodsController?.close();
  }
}