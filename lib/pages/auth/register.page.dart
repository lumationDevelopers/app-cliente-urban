import 'dart:convert';
import 'dart:io';

import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:client/pages/auth/register-social.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/auth.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:date_field/date_field.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_ip/get_ip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerForm = GlobalKey<FormState>();
  
  final _api = new Api();
  final _auth = new Auth();
  final _utils = new Utils();

  var firstName;
  var lastName;
  var phoneNumber;
  var gender;
  var email;
  var password;
  var username;
  var birthday;

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

  UserBloc bloc;
  CardsBloc cardsBloc;
  AddressBloc addressBloc;
  PaymentMethodsBloc paymentMethodsBloc;
  PaymentMethodSelectedBloc paymentMethodSelectedBloc;
  RideBloc rideBloc;
  RideStatusBloc rideStatusBloc;

  fbLogin(BuildContext context) async {
    final FacebookLogin facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    if (result.accessToken != null) {
      final token = result.accessToken.token;
      print(token);
      
      Navigator.of(context).pushNamed('auth/register/social', arguments: RegisterSocialPageArguments('facebooksignup', 'facebooksignin',{
        "id_token": token
      }));

    }


  }

  googleLogin(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email'
      ],
    );

    final result = await _googleSignIn.signIn();

    result.authentication.then((googleKey){
      print(googleKey.idToken);

      Navigator.of(context).pushNamed('auth/register/social', arguments: RegisterSocialPageArguments('googlesignup', 'googlesignin',{
        "id_token": googleKey.idToken
      }));
    }).catchError((err){
      print('inner error');
    });

    /*if (result.accessToken != null) {
      final token = result.accessToken.token;
      final response = await _auth.postByPath(context, 'facebooksignup', {
        "id_token": token
      });

      final responseData =  jsonDecode(response.body);
      if (response.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
      }

      final instance = await SharedPreferences.getInstance();

      instance.setString('user_token', responseData['access_token']);

      final userResponse = await _api.getByPath(context, 'auth/me');

      if (userResponse.statusCode != 200) {
        _utils.closeDialog(context);
        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');

        return Navigator.of(context).pushNamedAndRemoveUntil('auth/login', (_) => false);
      }

      final userData = jsonDecode(userResponse.body);

      final cardsResponse = await _api.getByPath(context, 'cards');

      if (cardsResponse.statusCode != 200) {
        _utils.closeDialog(context);
        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');
      }

      final cardsData = jsonDecode(cardsResponse.body);

      final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

      if (addressResponse.statusCode != 200) {
        _utils.closeDialog(context);
        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');
      }

      final addressData = jsonDecode(addressResponse.body);

      cardsBloc.modifyCards(cardsData['data']);
      addressBloc.modifyAddresses(addressData['data']);
      bloc.modifyUserData(userData['data']['user']);

      final paymentsResponse = await _api.getByPath(context, 'paymentmethods');

      final paymentsData = jsonDecode(paymentsResponse.body);
      if (paymentsResponse.statusCode == 200) {
        paymentMethodsBloc.modifyPaymentMethods(paymentsData['data']);
      } else {
        paymentMethodsBloc.modifyPaymentMethods([]);
      }

      print(paymentsData);
      if (cardsData['data'].length > 0) {
        paymentMethodSelectedBloc.modifyPaymentMethodSelected({
          ...(paymentsData['data'] as List).firstWhere((element) => element['_id'] == '5f188197ebddcb29eccc5eb5'),
          "card": cardsData['data'][0]['_id'],
          "last4": cardsData['data'][0]['last4'],
        });
      } else {
        paymentMethodSelectedBloc.modifyPaymentMethodSelected({
          ...(paymentsData['data'] as List).firstWhere((element) => element['_id'] == '5f188138ebddcb29eccc5eb4'),
        });
      }

      if (userData['data']['user']['current_trip'] != null) {

        final rideResponse = await _api.getByPath(context, 'trips/${userData['data']['user']['current_trip']}');

        if (rideResponse.statusCode != 200) {
          rideStatusBloc.modifyRideStatus('Pending');
          return Navigator.of(context).pushReplacementNamed('auth/login');
        }

        final rideData = jsonDecode(rideResponse.body);

        rideBloc.modifyRideData(rideData['data']);

        rideStatusBloc.modifyRideStatus('Started');
      } else {
        rideStatusBloc.modifyRideStatus('Pending');
      }

      _utils.closeDialog(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);

      print(responseData);

    }*/


  }

  @override
  Widget build(BuildContext context) {
    bloc = Provider.of(context).userBloc;
    cardsBloc = Provider.of(context).cardsBloc;
    addressBloc = Provider.of(context).addressBloc;
    paymentMethodsBloc =  Provider.of(context).paymentMethodsBloc;
    paymentMethodSelectedBloc =  Provider.of(context).paymentMethodSelectedBloc;
    rideBloc =  Provider.of(context).rideBloc;
    rideStatusBloc =  Provider.of(context).rideStatusBloc;

    return Scaffold(
      appBar: urbanAppBar(context, 'Regístrate', false),
      body: Container(
        child: Form(
          key: _registerForm,
          child: ListView(
            padding: EdgeInsets.all(26.0),
            children: <Widget>[
              TextFormField(
                validator: (v) => v == '' ? 'Este campo es obligatorio' : null,
                onChanged: (v) => username = v,
                decoration: InputDecoration(
                    labelText: 'Nombre de usuario'
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: TextFormField(
                      validator: (v) => v == '' ? 'Este campo es obligatorio' : null,
                      onChanged: (v) => firstName = v,
                      decoration: InputDecoration(
                          labelText: 'Nombre'
                      ),
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 8,
                    child: TextFormField(
                      validator: (v) => v == '' ? 'Este campo es obligatorio' : null,
                      onChanged: (v) => lastName = v,
                      decoration: InputDecoration(
                          labelText: 'Apellido'
                      ),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
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
                    child: TextFormField(
                      validator: (v) {
                        if (v == '') {
                          return 'Este campo es obligatorio';
                        }
                        if (v.length < 8) {
                          return 'Ingresa un número válido';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (v) => phoneNumber = v,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
                value: sharePhone,
                activeColor: Colors.black,
                onChanged: (v) {
                  setState(() {
                    sharePhone = v;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
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
                        icon: null,
                        iconSize: 0,
                        items: <String>['Masculino', 'Femenino'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value == 'Femenino' ? 'f' : 'm',
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
              Padding(padding: EdgeInsets.only(top: 16.0)),
              TextFormField(
                validator: (v) {
                  final RegExp validator = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (v == '') {
                    return 'Este campo es obligatorio';
                  }
                  if (!validator.hasMatch(v)) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
                onChanged: (v) => email = v,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    labelText: 'Correo electrónico'
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              TextFormField(
                validator: (v) => v == '' ? 'Este campo es obligatorio' : null,
                onChanged: (v) => password = v,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Contraseña'
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              DateTimeFormField(
                validator: (v) => v == null ? 'Este campo es obligatorio' : null,
                mode: DateFieldPickerMode.date,
                label: 'Fecha de nacimiento',
                decoration: InputDecoration(
                  prefixText: ''
                ),
                onDateSelected: (DateTime date) {
                  setState(() {
                    birthday = date;
                  });
                },
                lastDate: DateTime(2021),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              /*InkWell(
                onTap: () => Navigator.of(context).pushNamed('auth/register/card'),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 51.0,
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6.0),
                                bottomLeft: Radius.circular(6.0)
                            )
                        ),
                        child: Text('Agregar tarjeta de crédito o débito', style: TextStyle(color: Colors.grey[600], fontSize: 15.0)),
                      ),
                    ),
                    Expanded(
                        child:  Container(
                          height: 51.0,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6.0),
                                  bottomRight: Radius.circular(6.0)
                              )
                          ),
                          child: Icon(Icons.arrow_right, size: 42.0),
                        )
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 16.0)),*/
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Al crear tu cuenta, aceptas los ', style: TextStyle(fontFamily: 'Lato-Light', fontSize: 14.0)),
                  InkWell(
                    onTap: () async {
                      const url = 'https://www.urban.taxi/terms-and-conditions.html';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: Text('Términos y Condiciones',
                        style: TextStyle(
                          fontFamily: 'Lato-Light',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          decoration: TextDecoration.underline,
                        )
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 32.0)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.15),
                child: defaultButton(120.0, 'Regístrate', () async {
                  if (_registerForm.currentState.validate()) {
                    _registerForm.currentState.save();

                    _utils.loadingDialog(context);

                    final data = {
                      "terms_conditions_of_use": true,
                      "username": username,
                      "name": firstName,
                      "lastname": lastName,
                      "email": email,
                      "password": password,
                      "confirm_password": password,
                      "phone_number": '+${_selectedDialogCountry.phoneCode}$phoneNumber',
                      "whatsapp_number": phoneNumber,
                      "birthday": (birthday.toString()).split(' ')[0],
                      "gender": gender,
                      "share_phone": sharePhone
                    };
                    
                    final response = await _auth.postByPath(context, 'userRegister', data);

                    final responseData =  jsonDecode(response.body);
                    if (response.statusCode != 200) {
                      _utils.closeDialog(context);
                      return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
                    }

                    /*

                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    var deviceName;

                    if (Platform.isAndroid) {
                      deviceName = (await deviceInfo.androidInfo).model;
                    } else if (Platform.isIOS) {
                      deviceName = (await deviceInfo.iosInfo).utsname.machine;
                    }

                    final loginData = {
                      "grant_type": "password",
                      "username": email,
                      "password": password,
                      "deviceName": deviceName,
                      "ip": await GetIp.ipAddress
                    };

                    final loginResponse = await _auth.login(loginData);


                    if (loginResponse.statusCode == 200) {
                      final instance = await SharedPreferences.getInstance();

                      instance.setString('user_token', jsonDecode(loginResponse.body)['access_token']);

                      final userResponse = await _api.getByPath(context, 'auth/me');

                      if (userResponse.statusCode != 200) {
                        _utils.closeDialog(context);
                        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');

                        return Navigator.of(context).pushNamedAndRemoveUntil('auth/login', (_) => false);
                      }

                      final userData = jsonDecode(userResponse.body);

                      final cardsResponse = await _api.getByPath(context, 'cards');

                      if (cardsResponse.statusCode != 200) {
                        _utils.closeDialog(context);
                        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');
                      }

                      final cardsData = jsonDecode(cardsResponse.body);

                      final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

                      if (addressResponse.statusCode != 200) {
                        _utils.closeDialog(context);
                        _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');
                      }

                      final addressData = jsonDecode(addressResponse.body);

                      cardsBloc.modifyCards(cardsData['data']);
                      addressBloc.modifyAddresses(addressData['data']);
                      bloc.modifyUserData(userData['data']['user']);

                      _utils.closeDialog(context);
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);


                    } else {*/
                      _utils.closeDialog(context);
                      Navigator.of(context).pushNamedAndRemoveUntil('auth/welcome', (_) => false);
                      return _utils.messageDialog(context, 'Usuario creado', 'Se han enviado las instrucciones a tu correo electrónico para que verifiques tu cuenta.');
                    //}


                  }
                }),
              ),
              Padding(padding: EdgeInsets.only(top: 32.0)),
              Text('O regístrate con:', textAlign: TextAlign.center,),
              Padding(padding: EdgeInsets.only(top: 16.0)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () => fbLogin(context),
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          color: Colors.indigo[600],
                          borderRadius: BorderRadius.circular(18.0)
                      ),
                      child: Image.asset('assets/fb-icon.png'),
                    )
                  ),
                  Padding(padding: EdgeInsets.only(left: 18.0)),
                  InkWell(
                      onTap: () => googleLogin(context),
                      child: Container(
                        width: 64.0,
                        height: 64.0,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                            color: Colors.red[600],
                            borderRadius: BorderRadius.circular(18.0)
                        ),
                        child: Image.asset('assets/google-icon.png'),
                      )
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),

            ],
          ),
        )
      ),
    );
  }
}
