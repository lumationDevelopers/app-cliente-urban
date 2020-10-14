import 'dart:convert';

import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/auth.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterSocialPage extends StatefulWidget {
  @override
  _RegisterSocialPageState createState() => _RegisterSocialPageState();
}

class _RegisterSocialPageState extends State<RegisterSocialPage> {
  final _form = GlobalKey<FormState>();

  UserBloc bloc;
  CardsBloc cardsBloc;
  AddressBloc addressBloc;
  PaymentMethodsBloc paymentMethodsBloc;
  PaymentMethodSelectedBloc paymentMethodSelectedBloc;
  RideBloc rideBloc;
  RideStatusBloc rideStatusBloc;

  final _auth = new Auth();
  final _api = new Api();
  final _utils = new Utils();

  var username = '';
  var gender = '';

  String _debugLabelString = "";

  Future initPlatformState(userEmail) async {
    if (!mounted) return;

    await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    await OneSignal.shared.setRequiresUserPrivacyConsent(false);

    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.promptBeforeOpeningPushUrl: true,
      OSiOSSettings.inAppLaunchUrl: false
    };

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
        "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
        "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    await OneSignal.shared.init("d8d7f226-00d2-41ab-84c4-4bdf12b30c6d", iOSSettings: settings);

    await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    //await OneSignal.shared.setEmail(email: userEmail);

    final status = await OneSignal.shared.getPermissionSubscriptionState();
    String oneSignalUserId = status.subscriptionStatus.userId;

    final email = status.emailSubscriptionStatus.emailUserId;
    print(oneSignalUserId);
    print(email);

    return oneSignalUserId;

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
    final RegisterSocialPageArguments args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: urbanAppBar(context, 'Ingresa tu información', false),
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
                  onChanged: (v) => username = v,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)
                      ),
                    ),
                    labelText: 'Nombre de usuario',
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 16.0)),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 51.0,
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
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
                Padding(padding: EdgeInsets.only(top: 32.0)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15),
                  child: defaultButton(120.0, 'Continuar', () async {
                    if (_form.currentState.validate()) {
                      _form.currentState.save();

                      final response = await _auth.postByPath(context, args.path, {
                        ...args.data,
                        "username": username,
                        "gender": gender
                      });

                      final responseData = jsonDecode(response.body);
                      if (response.statusCode != 201) {
                        _utils.closeDialog(context);
                        if (response.statusCode == 422) {
                          return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
                        } else {
                          print(response.statusCode);
                          print(response.body);
                          return _utils.messageDialog(context, 'No se ha realizado el registro', 'Ocurrio un error.');
                        }

                      }

                      final loginResponse = await _auth.postByPath(context, args.loginPath, {
                        ...args.data,
                      });

                      if (loginResponse.statusCode != 201) {
                        _utils.closeDialog(context);
                        Navigator.of(context).pushNamedAndRemoveUntil('auth/welcome', (_) => false);
                        return _utils.messageDialog(context, 'Registrado', 'Tu registro fue exitoso pero no se ha iniciado sesión. Inténta iniciar sesión de nuevo.');
                      }

                      final loginData = jsonDecode(loginResponse.body);

                      final instance = await SharedPreferences.getInstance();

                      instance.setString('user_token', loginData['access_token']);

                      final userResponse = await _api.getByPath(context, 'auth/me');

                      if (userResponse.statusCode != 200) {
                        _utils.closeDialog(context);
                        Navigator.of(context).pushNamedAndRemoveUntil('auth/welcome', (_) => false);
                        return _utils.messageDialog(context, 'Usuario creado', 'Se ha creado tu usuarios. Ahora debes iniciar sesión');
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

                      initPlatformState(userData['data']['user']['email']);

                      _utils.closeDialog(context);
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);


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

class RegisterSocialPageArguments {
  final String path;
  final String loginPath;
  final Map<String, dynamic> data;

  RegisterSocialPageArguments(this.path, this.loginPath,  this.data);
}