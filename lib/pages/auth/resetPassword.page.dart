import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/auth.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _auth = new Auth();
  final _utils = new Utils();

  var email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.only(left: 14.0),
            child: SvgPicture.asset('assets/back-icon.svg', color: Colors.black),
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(26.0),
          child: Form(
            key: _form,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 37.0, fontWeight: FontWeight.bold,)),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Container(
                  width: double.infinity,
                  child: Text('Ingresa tu correo electrónico y recibirás las instrucciones para restablecerla', style: TextStyle(fontSize: 18.0, fontFamily: 'Lato-Light')),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
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
                  child: defaultButton(double.infinity, 'Continuar', () async {
                    if (_form.currentState.validate()) {
                      _form.currentState.save();

                      _utils.loadingDialog(context);


                      final response = await _auth.postByPath(context, 'forgotpassword', {
                        "email": email
                      });

                      final data = jsonDecode(response.body);

                      print(data);
                      if (response.statusCode != 200) {
                        _utils.closeDialog(context);
                        return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                      }

                      _utils.closeDialog(context);

                      Navigator.of(context).pop();

                      _utils.messageDialog(context, 'Solicitud recibida', 'Se ha enviado los pasos para recuperar tu contraseña a tu correo electrónico');

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
