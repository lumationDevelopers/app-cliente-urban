import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/user/changePasswordStep2.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';

class ChangePasswordStep1Page extends StatefulWidget {
  @override
  _ChangePasswordStep1PageState createState() => _ChangePasswordStep1PageState();
}

class _ChangePasswordStep1PageState extends State<ChangePasswordStep1Page> {
  final _form = GlobalKey<FormState>();

  var currentPassword = '';

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
  @override
  Widget build(BuildContext context) {
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
                      return 'Este campo s obligatorio';
                    }
                    return null;
                  },
                  onChanged: (v) => currentPassword = v,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)
                      ),
                    ),
                    labelText: 'Contraseña actual',
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

                      Navigator.of(context).pushNamed('user/change-password-2', arguments: ChangePasswordStep2PageArguments(currentPassword));
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
