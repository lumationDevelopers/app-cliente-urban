import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';

class ChangeEmailPage extends StatefulWidget {
  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  var email = '';

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;

    setState(() {
      email = bloc.userInfo['email'];
    });
    return Scaffold(
      appBar: urbanAppBar(context, 'Correo electrónico', false),
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
                    if (v.length < 8) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                  initialValue: email,
                  onChanged: (v) => email = v,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)
                      ),
                    ),
                    labelText: 'Correo electrónico',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15),
                  child: defaultButton(120.0, 'Actualizar', () async {
                    if (_form.currentState.validate()) {
                      _form.currentState.save();

                      _utils.loadingDialog(context);

                      print(bloc.userInfo['_id']);

                      final response = await _api.putByPath(context, 'users/${bloc.userInfo['_id']}', {
                        "email": email
                      });

                      final data = jsonDecode(response.body);
                      if (data['success'] == false) {
                        _utils.closeDialog(context);
                        return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                      }

                      bloc.modifyUserData(data['data']);

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
