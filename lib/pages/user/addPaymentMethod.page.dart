import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPaymentMethodPage extends StatefulWidget {
  @override
  _AddPaymentMethodPageState createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _form = GlobalKey<FormState>();

  final _expireDateController = new TextEditingController();

  final _api = Api();
  final _utils = Utils();

  var cardNumber;
  var cardName;
  var cardDate;
  var cvv;

  var cardMonth;
  var cardYear;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //BackButtonInterceptor.add(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.of(context).pop();
    return true;

  }

  @override
  void dispose() {
    super.dispose();
    //BackButtonInterceptor.remove(myInterceptor);
  }

  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _cardNameFocus = FocusNode();
  final FocusNode _cardMonthFocus = FocusNode();
  final FocusNode _cardYearFocus = FocusNode();
  final FocusNode _cardCVVFocus = FocusNode();

  UserBloc userBloc;
  CardsBloc cardsBloc;
  void addCard(BuildContext context) async {
    if (_form.currentState.validate()) {
      _form.currentState.save();

      _utils.loadingDialog(context);

      print(userBloc.userInfo['_id']);

      print(cardMonth);

      final body = {
        'user': userBloc.userInfo['_id'],
        'card_name': cardName,
        'card_number': cardNumber,
        'expire_month': cardMonth,
        'expire_year': cardYear,
        'cvv': cvv
      };

      final response = await _api.postByPath(context, 'cards', body);

      final data = jsonDecode(response.body);
      ;
      if (data['success'] == false) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
      }

      final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userBloc.userInfo['_id']}');

      if (cardsResponse.statusCode == 200) {
        final cardsData = jsonDecode(cardsResponse.body);
        cardsBloc.modifyCards(cardsData['data']);
      } else {
        _utils.messageDialog(context, 'Tarjeta agregada', 'Se agrego tu tarjeta pero hubo algún error al cargar tus datos. Inténta reiniciar el app');
      }

      _utils.closeDialog(context);

      Navigator.of(context).pop();

    }
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of(context).userBloc;
    cardsBloc = Provider.of(context).cardsBloc;

    return Scaffold(
      appBar: urbanAppBar(context, 'Nuevo método de pago', false),
      body: Container(
          child: Form(
            key: _form,
            child: ListView(
              padding: EdgeInsets.all(26.0),
              children: <Widget>[
                TextFormField(
                  validator: (v) {
                    if (v == '') {
                      return 'Este campo s obligatorio';
                    }
                    if (v.length < 13) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                  initialValue: cardNumber,
                  focusNode: _cardNumberFocus,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term){
                    _fieldFocusChange(context, _cardNumberFocus, _cardNameFocus);
                  },
                  onChanged: (v) => cardNumber = v,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Número de tarjeta',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                TextFormField(
                  validator: (v) {
                    if (v == '') {
                      return 'Este campo es obligatorio';
                    }
                    return null;
                  },
                  initialValue: cardName,
                  onFieldSubmitted: (term){
                    _fieldFocusChange(context, _cardNameFocus, _cardMonthFocus);
                  },
                  focusNode: _cardNameFocus,
                  onChanged: (v) => cardName = v,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Titular de la tarjeta',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 14,
                      child: TextFormField(
                        validator: (v) {

                          if (v == '') {
                            return 'Este campo es obligatorio';
                          }

                          if (v.length != 2) {
                            return 'El formato es incorrecto';
                          }
                          return null;
                        },
                        onChanged: (v) => cardMonth = v,
                        focusNode: _cardMonthFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (term){
                          _fieldFocusChange(context, _cardMonthFocus, _cardYearFocus);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          labelText: 'Mes',
                          hintText: 'MM'
                        ),
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 16,
                      child: TextFormField(
                        validator: (v) {

                          if (v == '') {
                            return 'Este campo es obligatorio';
                          }

                          if (v.length != 4) {
                            return 'El formato es incorrecto';
                          }
                          return null;
                        },
                        onChanged: (v) => cardYear = v,
                        textInputAction: TextInputAction.next,
                        focusNode: _cardYearFocus,
                        onFieldSubmitted: (term){
                          _fieldFocusChange(context, _cardYearFocus, _cardCVVFocus);
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                            labelText: 'Año',
                            hintText: 'YYYY'
                        ),
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 14,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == '') {
                            return 'Este campo es obligatorio';
                          }

                          if (v.length < 3 || v.length > 4) {
                            return 'Ingresa un número válido';
                          }

                          return null;
                        },
                        onChanged: (v) => cvv = v,
                        focusNode: _cardCVVFocus,
                        onFieldSubmitted: (term){
                          _cardCVVFocus.unfocus();
                          addCard(context);
                        },
                        decoration: InputDecoration(
                            labelText: 'CVV'
                        ),
                      ),
                    )
                  ],
                ),
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15),
                  child: defaultButton(120.0, 'Agregar', () => addCard(context) ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
