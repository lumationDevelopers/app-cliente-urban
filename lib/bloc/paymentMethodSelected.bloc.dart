import 'dart:async';
import 'package:rxdart/rxdart.dart';


class PaymentMethodSelectedBloc {

  final _paymentMethodSelectedController = BehaviorSubject<Map<String, dynamic>>();

  Function(Map<String, dynamic>) get modifyPaymentMethodSelected => _paymentMethodSelectedController.sink.add;

  Stream<Map<String, dynamic>> get paymentMethodSelectedStream => _paymentMethodSelectedController.stream;

  Map<String, dynamic> get paymentMethodSelect => _paymentMethodSelectedController.value;

  dispose() {
    _paymentMethodSelectedController?.close();
  }
}
