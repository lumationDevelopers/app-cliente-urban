import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of(context).userBloc;
    final cardsBloc = Provider.of(context).cardsBloc;

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
                  onChanged: (v) => cardNumber = v,
                  keyboardType: TextInputType.text,
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
                  onChanged: (v) => cardName = v,
                  keyboardType: TextInputType.number,
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

                          if (v.length != 7) {
                            return 'El formato es incorrecto';
                          }
                          return null;
                        },
                        controller: _expireDateController,
                        onChanged: (v) {
                          if (v.length == 2) {
                            setState(() {
                              _expireDateController.text = '$v/';
                            });

                          }
                          cardDate = v;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          labelText: 'Vencimiento',
                          hintText: 'MM/YYYY'
                        ),
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 8,
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
                  child: defaultButton(120.0, 'Agregar', () async {
                    if (_form.currentState.validate()) {
                      _form.currentState.save();

                      _utils.loadingDialog(context);

                      print(userBloc.userInfo['_id']);

                      final body = {
                        'user': userBloc.userInfo['_id'],
                        'card_name': cardName,
                        'card_number': cardNumber,
                        'expire_month': cardDate.split('/')[0],
                        'expire_year': cardDate.split('/')[1],
                        'cvv': cvv
                      };

                      final response = await _api.postByPath(context, 'cards', body);

                      final data = jsonDecode(response.body);
                      ;
                      if (data['success'] == false) {
                        _utils.closeDialog(context);
                        return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                      }

                      List cards = cardsBloc.cards;
                      cards.add(data['data']);

                      cardsBloc.modifyCards(cards);

                      _utils.closeDialog(context);

                      Navigator.of(context).pop();

                    }
                  }),
                ),
              ],
            ),
          )
      ),
    );
  }
}
