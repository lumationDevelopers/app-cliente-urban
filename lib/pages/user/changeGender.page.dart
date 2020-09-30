import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';

class ChangeGenderPage extends StatefulWidget {
  @override
  _ChangeGenderPageState createState() => _ChangeGenderPageState();
}

class _ChangeGenderPageState extends State<ChangeGenderPage> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  var gender;
  var contactMeByPhone = false;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;

    print(bloc.userInfo['gender']);

    setState(() {
      gender = bloc.userInfo['gender'] ? 'female' : 'male';
    });
    return Scaffold(
      appBar: urbanAppBar(context, 'Género', false),
      body: Container(
          child: Form(
            key: _form,
            child: ListView(
              padding: EdgeInsets.all(26.0),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6.0),
                                bottomLeft: Radius.circular(6.0)
                            )
                        ),
                        child:  DropdownButtonFormField<String>(
                          validator: (v) => v == '' ? 'Este campo es obligatorio' : null,
                          onChanged: (v) => gender = v,
                          isExpanded: true,
                          value: gender,
                          icon: null,
                          iconSize: 0,
                          items: <String>['Masculino', 'Femenino'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value == 'Femenino' ? 'female' : 'male',
                              child: new Text(value),
                            );
                          }).toList(),
                          hint: Text('Género'),
                          decoration: InputDecoration.collapsed(hintText: null),

                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                          height: 51.0,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6.0),
                                  bottomRight: Radius.circular(6.0)
                              )
                          ),
                          child: Icon(Icons.arrow_drop_down, size: 42.0)
                      ),
                    ),
                  ],
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
                        "gender": gender
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
