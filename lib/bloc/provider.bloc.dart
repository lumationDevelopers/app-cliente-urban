import 'package:bloc/bloc.dart';
import 'package:client/bloc/addCardOnRegister.bloc.dart';
import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/cardSelected.bloc.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/chat.bloc.dart';
import 'package:client/bloc/chatSocket.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:flutter/material.dart';

class Provider extends InheritedWidget {

  static Provider _instance;

  factory Provider({Key key, Widget child}) {
    if (_instance == null) {
      _instance = new Provider._internal(key: key, child: child);
    }

    return _instance;
  }

  final userBloc = UserBloc();
  final rideBloc = RideBloc();
  final addressBloc = AddressBloc();
  final paymentMethodsBloc = PaymentMethodsBloc();
  final chatBloc = ChatBloc();
  final chatSocketBloc = ChatSocketBloc();
  final cardsBloc = CardsBloc();
  final cardSelectedBloc = CardSelectedBloc();
  final rideStatusBloc = RideStatusBloc();
  final paymentMethodSelectedBloc = PaymentMethodSelectedBloc();
  final addCardOnRegister = AddCardOnRegisterBloc();

  Provider._internal({Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static Provider of (BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<Provider>());
  }

}