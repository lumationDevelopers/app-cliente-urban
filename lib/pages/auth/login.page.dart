import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/auth.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:io';

import 'package:get_ip/get_ip.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginForm = GlobalKey<FormState>();

  final _auth = new Auth();
  final _api = new Api();
  final _utils = new Utils();

  var _email = '';
  var _password = '';

  String _debugLabelString = "";

  Future initPlatformState(userEmail) async {
    /*await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    //await OneSignal.shared.setRequiresUserPrivacyConsent(false);

    var settings = {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: false
    };

    /*OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
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

     */

    await OneSignal.shared.init("d8d7f226-00d2-41ab-84c4-4bdf12b30c6d", iOSSettings: settings);

    await OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    //await OneSignal.shared.setEmail(email: userEmail);*/

    final status = await OneSignal.shared.getPermissionSubscriptionState();
    String oneSignalUserId = status.subscriptionStatus.userId;
    return oneSignalUserId;

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  UserBloc bloc;
  CardsBloc cardsBloc;
  AddressBloc addressBloc;
  PaymentMethodsBloc paymentMethodsBloc;
  PaymentMethodSelectedBloc paymentMethodSelectedBloc;
  RideBloc rideBloc;
  RideStatusBloc rideStatusBloc;

  fbLogin(BuildContext context) async {
    _utils.loadingDialog(context);
    final FacebookLogin facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    if (result.accessToken != null) {
      final token = result.accessToken.token;
      final response = await _auth.postByPath(context, 'facebooksignin', {
        "id_token": token
      });

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode != 201) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
      }

      final instance = await SharedPreferences.getInstance();

      instance.setString('user_token', responseData['access_token']);

      final userResponse = await _api.getByPath(context, 'auth/me');

      print(userResponse.body);
      if (userResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );

      }

      final userData = jsonDecode(userResponse.body);

      final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

      if (cardsResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
      }

      final cardsData = jsonDecode(cardsResponse.body);

      final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

      if (addressResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
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
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'tarjeta'),
          "card": cardsData['data'][0]['_id'],
          "last4": cardsData['data'][0]['last4'],
        });
      } else {
        paymentMethodSelectedBloc.modifyPaymentMethodSelected({
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'efectivo'),
        });
      }

      if (userData['data']['user']['current_trip'] != null) {

        final rideResponse = await _api.getByPath(context, 'trips/${userData['data']['user']['current_trip']}');

        if (rideResponse.statusCode != 200) {
          rideStatusBloc.modifyRideStatus('Pending');
          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
        }

        final rideData = jsonDecode(rideResponse.body);

        rideBloc.modifyRideData(rideData['data']);

        rideStatusBloc.modifyRideStatus('Started');
      } else {
        rideStatusBloc.modifyRideStatus('Pending');
      }

      initPlatformState(userData['data']['user']['email']).then((playerId) {
        _api.putByPath(context, 'users/addplayerid', {
          "playerid": playerId
        });
      });

      _utils.closeDialog(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);

      print(responseData);

    } else {
      _utils.closeDialog(context);
      _utils.messageDialog(context, 'Error', 'Hubo un error al conectar con los servicios de Facebook. Inténtalo de nuevo');
    }


  }

  googleLogin(BuildContext context) async {
    _utils.loadingDialog(context);
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email'
      ],
    );

    final result = await _googleSignIn.signIn();

    _utils.closeDialog(context);

    result.authentication.then((googleKey) async {
      print(googleKey.idToken);

      _utils.loadingDialog(context);

      String token;
      String platform;

      if (Platform.isAndroid) {
        platform = 'android';
        token = googleKey.idToken;
      } else {
        platform = 'ios';
        token = googleKey.idToken;
      }

      final response = await _auth.postByPath(context, 'googlesignin', {
        "id_token": token,
        "os": platform
      });

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode != 201) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
      }

      final instance = await SharedPreferences.getInstance();

      instance.setString('user_token', responseData['access_token']);

      final userResponse = await _api.getByPath(context, 'auth/me');

      print(userResponse.body);
      if (userResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );

      }

      final userData = jsonDecode(userResponse.body);

      final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

      if (cardsResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
      }

      final cardsData = jsonDecode(cardsResponse.body);

      final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

      if (addressResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
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
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'tarjeta'),
          "card": cardsData['data'][0]['_id'],
          "last4": cardsData['data'][0]['last4'],
        });
      } else {
        paymentMethodSelectedBloc.modifyPaymentMethodSelected({
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'efectivo'),
        });
      }

      if (userData['data']['user']['current_trip'] != null) {

        final rideResponse = await _api.getByPath(context, 'trips/${userData['data']['user']['current_trip']}');

        if (rideResponse.statusCode != 200) {
          rideStatusBloc.modifyRideStatus('Pending');
          _utils.closeDialog(context);
          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
        }

        final rideData = jsonDecode(rideResponse.body);

        rideBloc.modifyRideData(rideData['data']);

        rideStatusBloc.modifyRideStatus('Started');
      } else {
        rideStatusBloc.modifyRideStatus('Pending');
      }

      initPlatformState(userData['data']['user']['email']).then((playerId) {
        _api.putByPath(context, 'users/addplayerid', {
          "playerid": playerId
        });
      });

      _utils.closeDialog(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);

      print(responseData);
    }).catchError((err){
      _utils.messageDialog(context, 'Error', 'Hubo un error al conectar con los servicios de Google. Inténtalo de nuevo');
    });

  }


  appleLogin(BuildContext context) async {
    _utils.loadingDialog(context);
    SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    ).then((credential) async {

      String token;
      String platform;

      final response = await _auth.postByPath(context, 'applesignin', {
        "appleid": credential.userIdentifier,
        "identity_token": credential.identityToken,
        "authorization_code": credential.authorizationCode
      });

      final responseData = jsonDecode(response.body);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode != 201) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se ha realizado el registro', responseData['error']['errors'][0]);
      }

      final instance = await SharedPreferences.getInstance();

      instance.setString('user_token', responseData['access_token']);

      final userResponse = await _api.getByPath(context, 'auth/me');

      print(userResponse.body);
      if (userResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );

      }

      final userData = jsonDecode(userResponse.body);

      final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

      if (cardsResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
      }

      final cardsData = jsonDecode(cardsResponse.body);

      final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

      if (addressResponse.statusCode != 200) {
        _utils.closeDialog(context);
        return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
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
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'tarjeta'),
          "card": cardsData['data'][0]['_id'],
          "last4": cardsData['data'][0]['last4'],
        });
      } else {
        paymentMethodSelectedBloc.modifyPaymentMethodSelected({
          ...(paymentsData['data'] as List).firstWhere((element) => element['name'] == 'efectivo'),
        });
      }

      if (userData['data']['user']['current_trip'] != null) {

        final rideResponse = await _api.getByPath(context, 'trips/${userData['data']['user']['current_trip']}');

        if (rideResponse.statusCode != 200) {
          rideStatusBloc.modifyRideStatus('Pending');
          _utils.closeDialog(context);
          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
        }

        final rideData = jsonDecode(rideResponse.body);

        rideBloc.modifyRideData(rideData['data']);

        rideStatusBloc.modifyRideStatus('Started');
      } else {
        rideStatusBloc.modifyRideStatus('Pending');
      }

      initPlatformState(userData['data']['user']['email']).then((playerId) {
        _api.putByPath(context, 'users/addplayerid', {
          "playerid": playerId
        });
      });

      _utils.closeDialog(context);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);

      print(responseData);

    }).catchError((onError) {
      _utils.closeDialog(context);
      _utils.messageDialog(context, 'No se inicio sesión', 'No se pudo iniciar sesión. Inténtalo de nuevo');
    });

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
      appBar: urbanAppBar(context, 'Inicia sesión', false),
      body: Container(
        padding: EdgeInsets.only(left: 32.0, right: 32.0, top: 48.0),
        child: Form(
          key: _loginForm,
          child: Column(
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == '' ? 'Debes llenar este campo' : null,
                onChanged: (value) => {
                  setState(() {
                    _email = value;
                  })
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Correo eletrónico'
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
              ),
              TextFormField(
                obscureText: true,
                validator: (value) => value == '' ? 'Debes llenar este campo' : null,
                onChanged: (value) => {
                  setState(() {
                    _password = value;
                  })
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Contraseña',
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('auth/reset-password'),
                child: Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16.0
                    ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 42.0,
                ),
              ),
              Center(
                child: defaultButton(
                    MediaQuery.of(context).size.width * 0.55,
                    'Iniciar sesión',
                        () async {
                      if (_loginForm.currentState.validate()) {
                        _loginForm.currentState.save();

                        _utils.loadingDialog(context);

                        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                              var deviceName;

                              if (Platform.isAndroid) {
                                deviceName = (await deviceInfo.androidInfo).model;
                              } else if (Platform.isIOS) {
                                deviceName = (await deviceInfo.iosInfo).utsname.machine;
                              }

                        final data = {
                          "grant_type": "password",
                          "username": _email,
                          "password": _password,
                          "deviceName": deviceName,
                          "ip": await GetIp.ipAddress
                        };

                        final response = await _auth.login(data);

                        if (response.statusCode != 200) {
                          _utils.closeDialog(context);
                          return _utils.messageDialog(context, 'No se inicio sesión', jsonDecode(response.body)['error']['errors'][0]);
                        }

                        final instance = await SharedPreferences.getInstance();

                        instance.setString('user_token', jsonDecode(response.body)['access_token']);

                        final userResponse = await _api.getByPath(context, 'auth/me');

                        if (userResponse.statusCode != 200) {
                          _utils.closeDialog(context);
                          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
                        }

                        final userData = jsonDecode(userResponse.body);

                        final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

                        if (addressResponse.statusCode != 200) {
                          _utils.closeDialog(context);
                          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
                        }

                        final addressData = jsonDecode(addressResponse.body);

                        final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

                        print(cardsResponse);
                        if (cardsResponse.statusCode != 200) {
                          _utils.closeDialog(context);

                          return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
                        }

                        final cardsData = jsonDecode(cardsResponse.body);

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
                            _utils.closeDialog(context);
                            return _utils.messageDialog(context, 'No se inicio sesión', 'Hubo algún error en el servidor. Inténtalo de nuevo' );
                          }

                          final rideData = jsonDecode(rideResponse.body);

                          rideBloc.modifyRideData(rideData['data']);

                          rideStatusBloc.modifyRideStatus('Started');
                        } else {
                          rideStatusBloc.modifyRideStatus('Pending');
                        }

                        _utils.closeDialog(context);

                        initPlatformState(userData['data']['user']['email']).then((playerId) {
                          _api.putByPath(context, 'users/addplayerid', {
                            "playerid": playerId
                          });
                        });

                        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
                      }

                    }
                )
              ),
              Padding(padding: EdgeInsets.only(top: 32.0)),
              Text('O inicia sesión con:', textAlign: TextAlign.center),
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
                  ),
                  if (Platform.isIOS)
                    Padding(padding: EdgeInsets.only(left: 18.0)),
                    InkWell(
                        onTap: () => appleLogin(context),
                        child: Container(
                          width: 64.0,
                          height: 64.0,
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(18.0)
                          ),
                          child: Image.asset('assets/apple-icon.png'),
                        )
                    )
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),
            ],
          ),
        )
      )
    );
  }
}
