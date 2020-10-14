import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/cardSelected.bloc.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  RideBloc rideBloc;
  RideStatusBloc rideStatusBloc;
  CardsBloc cardsBloc;
  CardSelectedBloc cardSelectedBloc;
  UserBloc bloc;
  AddressBloc addressBloc;
  PaymentMethodsBloc paymentMethodsBloc;
  PaymentMethodSelectedBloc paymentMethodSelectedBloc;

  void _logout(BuildContext context) async {
    final instance = await SharedPreferences.getInstance();

    instance.remove('user_token');

    rideBloc.modifyRideData(null);
    rideStatusBloc.modifyRideStatus(null);
    cardsBloc.modifyCards(null);
    cardSelectedBloc.modifyCardSelected(null);
    bloc.modifyUserData(null);
    addressBloc.modifyAddresses(null);
    paymentMethodsBloc.modifyPaymentMethods(null);
    paymentMethodSelectedBloc.modifyPaymentMethodSelected(null);

    Navigator.of(context).pushNamedAndRemoveUntil('auth/welcome', (_) => false);
  }

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
    bloc = Provider.of(context).userBloc;
    rideBloc = Provider.of(context).rideBloc;
    rideStatusBloc = Provider.of(context).rideStatusBloc;
    cardsBloc = Provider.of(context).cardsBloc;
    cardSelectedBloc = Provider.of(context).cardSelectedBloc;
    addressBloc = Provider.of(context).addressBloc;
    paymentMethodsBloc = Provider.of(context).paymentMethodsBloc;
    paymentMethodSelectedBloc = Provider.of(context).paymentMethodSelectedBloc;

    return Scaffold(
      appBar: urbanAppBar(context, 'Configuración', true),
      body: ListView(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0),
                child: Text(
                  "Datos personales",
                  style: TextStyle(fontFamily: 'Lato-Light', fontSize: 22.0),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('user/profile'),
                child: ListTile(
                    title: StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Text(
                            '${snapshot.data['name']} ${snapshot.data['lastname']}',
                            style: TextStyle(fontSize: 20.0),
                          );
                        } else {
                          return Text('');
                        }

                      },
                    ),
                    subtitle: StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Text(
                            bloc.userInfo['phone_number'] ?? '',
                            style: TextStyle(fontSize: 20.0, fontFamily: 'Lato-Light', color: Colors.black),
                          );
                        } else {
                          return Text('');
                        }
                      },
                    ),
                    leading: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(42.0),
                        child: StreamBuilder(
                          stream: bloc.userStream,
                          builder: (context, snapshot) {
                            if (snapshot.data == null || snapshot.data['avatar'] == null) {
                              return Icon(Icons.person_outline, size: 42.0, color: Colors.black,);
                            } else {
                              return Image.network(
                                snapshot.data['avatar'].toString() ?? '',
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        )
                      ),
                    ),
                    trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[800],
                        size: 42.0
                    ),
                ),
              )
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('user/favorite-locations'),
                child: ListTile(
                    title: Text(
                      'Direcciones favoritas',
                      style: TextStyle(fontSize: 20.0, fontFamily: 'Lato-Light'),
                    ),
                    trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[800],
                        size: 42.0
                    ),
                ),
              )
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
              ),
              child: InkWell(
                onTap: () => null /*Navigator.of(context).pushNamed('user/email')*/,
                child: ListTile(
                    title: Text(
                      'Correo electrónico',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light'),
                    ),
                    subtitle: StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          return Text(
                            bloc.userInfo['email'],
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Lato-Light',
                                fontSize: 22.0
                            ),
                          );
                        } else {
                          return Text('');
                        }
                      },
                    ),
                ),
              )
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
              ),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('user/change-password-1'),
                child: ListTile(
                    title: Text(
                      'Contraseña',
                      style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light'),
                    ),
                    subtitle: Text('••••••••', style: TextStyle(color: Colors.black)),
                    trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[800],
                        size: 42.0
                    ),
                ),
              )
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
              ),
              child: InkWell(
                onTap: () async {
                  const url = 'https://www.urban.taxi/terms-and-conditions.html';
                  if (await canLaunch(url)) {
                  await launch(url);
                  } else {
                  throw 'Could not launch $url';
                  }
                },
                child: ListTile(
                    title: Text(
                      'Privacidad',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Lato-Light'
                      ),
                    ),
                    trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey[800],
                        size: 42.0
                    ),
                ),
              )
            ),
            InkWell(
              onTap: () => _logout(context),
              child: Container(
                padding: EdgeInsets.only(top: 42.0, left: 18.0),
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontSize: 18.0),
                ),
              ),
            ),
            Image.asset('assets/logo-urban.png', scale: 5.0)
          ],
      ),
    );
  }
}
