import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';

class ChangePasswordStep2Page extends StatefulWidget {
  @override
  _ChangePasswordStep2PageState createState() => _ChangePasswordStep2PageState();
}

class _ChangePasswordStep2PageState extends State<ChangePasswordStep2Page> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  var newPassword = '';
  var newPasswordConfirm = '';

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;
    final ChangePasswordStep2PageArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: urbanAppBar(context, 'Cambiar Contraseña', false),
      body: Container(
          child: Form(
            key: _form,
            child: ListView(
              padding: EdgeInsets.all(26.0),
              children: <Widget>[
                TextFormField(
                  validator: (v) {
                    if (v == '') {
                      return 'Este campo es obligatorio';
                    }

                    return null;
                  },
                  onChanged: (v) => newPassword = v,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)
                      ),
                    ),
                    labelText: 'Nueva contraseña',
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
                  obscureText: true,
                  onChanged: (v) => newPasswordConfirm = v,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)
                      ),
                    ),
                    labelText: 'Confirmar nueva contraseña',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15),
                  child: defaultButton(120.0, 'Continuar', () async {
                    if (_form.currentState.validate()) {
                      _form.currentState.save();

                      _utils.loadingDialog(context);


                      final response = await _api.putByPath(context, 'users/${bloc.userInfo['_id']}', {
                        "password": args.currentPassword,
                        "newpassword": newPassword,
                        "confirmpassword": newPasswordConfirm
                      });

                      final data = jsonDecode(response.body);

                      print(data);
                      _utils.closeDialog(context);
                      if (response.statusCode != 200) {
                        if (response.statusCode != 422) {
                          return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                        } else {
                          return _utils.messageDialog(context, 'Error', 'Ocurrio un error desconocido. Inténtalo de nuevo');
                        }

                      }

                      Navigator.of(context).pop();
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

class ChangePasswordStep2PageArguments {
  final String currentPassword;

  ChangePasswordStep2PageArguments(this.currentPassword);
}