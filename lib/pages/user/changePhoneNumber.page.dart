import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';

class ChangePhoneNumberPage extends StatefulWidget {
  @override
  _ChangePhoneNumberPageState createState() => _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends State<ChangePhoneNumberPage> {
  final _form = GlobalKey<FormState>();

  final _api = new Api();
  final _utils = new Utils();

  var phoneNumber = '';
  var contactMeByPhone = false;

  bool sharePhone = true;

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByPhoneCode('502');

  Widget _buildDialogItem(Country country) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      CountryPickerUtils.getDefaultFlagImage(country),
      SizedBox(width: 6.0),
      Text("+${country.phoneCode}"),
      SizedBox(width: 8.0),
      Flexible(child: Text(country.name, overflow: TextOverflow.ellipsis))
    ],
  );


  void _openCountryPickerDialog() => showDialog(
    context: context,
    builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.pink),
        child: CountryPickerDialog(
            titlePadding: EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: InputDecoration(hintText: 'Buscar país'),
            isSearchable: true,
            //title: Text('Select your phone code'),
            onValuePicked: (Country country) =>
                setState(() => _selectedDialogCountry = country),
            //itemFilter: (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
            priorityList: [
              CountryPickerUtils.getCountryByIsoCode('GT'),
            ],
            itemBuilder: _buildDialogItem)),
  );

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;

    setState(() {
      //phoneNumber = bloc.userInfo['phone_number'];
      sharePhone = bloc.userInfo['share_phone'];
    });
    return Scaffold(
      appBar: urbanAppBar(context, 'Número de teléfono', false),
      body: Container(
          child: Form(
            key: _form,
            child: ListView(
              padding: EdgeInsets.all(26.0),
              children: <Widget>[
                Container(
                  height: 56.0,
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: ListTile(
                    onTap: _openCountryPickerDialog,
                    title: _buildDialogItem(_selectedDialogCountry),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        validator: (v) {
                          if (v == '') {
                            return 'Este campo s obligatorio';
                          }
                          if (v.length < 8) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                        initialValue: phoneNumber,
                        onChanged: (v) => phoneNumber = v,
                        onTap: () {
                          setState(() {
                            phoneNumber = '';
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6.0))
                          ),
                          labelText: 'Número de teléfono',
                        ),
                      ),
                    )
                  ],
                ),
                CheckboxListTile(
                  title: Text(
                    "El piloto puede contactarme por esta via.",
                    style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  activeColor: Colors.black,
                  value: contactMeByPhone,
                  onChanged: (v) {
                    setState(() {
                      contactMeByPhone = v;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
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

                      print('+${_selectedDialogCountry.phoneCode}$phoneNumber');

                      final response = await _api.putByPath(context, 'users/${bloc.userInfo['_id']}', {
                        "phone_number": '+${_selectedDialogCountry.phoneCode}$phoneNumber',
                        "share_phone": sharePhone
                      });

                      print(response.body);

                      final data = jsonDecode(response.body);
                      if (data['success'] == false) {
                        _utils.closeDialog(context);
                        return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                      }

                      print(data['data']);

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
