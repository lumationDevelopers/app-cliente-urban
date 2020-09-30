import 'dart:async';
import 'dart:convert';

import 'package:client/pages/home.page.dart';
import 'package:client/pages/user/profile.page.dart';
import 'package:client/pages/user/settings.page.dart';
import 'package:client/routes/routes.dart';
import 'package:client/services/api.service.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'bloc/provider.bloc.dart';

void main() {
  runApp(UrbanApp());
}

class UrbanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Provider(
      child: MaterialApp(
        title: 'Urban Taxi',
        home: StartPage(),
        routes: routes,
        initialRoute: '',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case 'user/profile':
            return CupertinoPageRoute(
                builder: (_) => ProfilePage(), settings: settings);
            /*PageRouteBuilder(
              pageBuilder: (_, Animation<double> animation, Animation<double> secondaryAnimation) => ProfilePage(),
              transitionsBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                );
              },
            );*/
            case 'user/settings':
              return CupertinoPageRoute(
                  builder: (_) => SettingsPage(), settings: settings);
          }
          // unknown route
          return MaterialPageRoute(builder: (context) => HomePage());
        },
        theme: ThemeData(
            fontFamily: 'Lato',
            primaryColor: Colors.black,
            accentColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0)
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8
              ),

            ),
            buttonTheme: ButtonThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                buttonColor: Colors.black,
                textTheme: ButtonTextTheme.accent
            )
        ),
      ),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  AlignmentGeometry _alignment = Alignment.center;

  bool showLoader = false;

  final _api = new Api();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () => _changeAlignment());
  }

  void _changeAlignment() {
    setState(() {
      _alignment = Alignment.topCenter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;
    final addressBloc = Provider.of(context).addressBloc;
    final cardsBloc = Provider.of(context).cardsBloc;
    final rideStatusBloc = Provider.of(context).rideStatusBloc;
    final rideBloc = Provider.of(context).rideBloc;
    final paymentMethodsBloc = Provider.of(context).paymentMethodsBloc;
    final paymentMethodSelectedBloc = Provider.of(context).paymentMethodSelectedBloc;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: bloc.userStream,
              builder: (context, snapshot) {
                return Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: AnimatedAlign(
                      alignment: _alignment,
                      curve: Curves.ease,
                      onEnd: () async {
                        final instance = await SharedPreferences.getInstance();
                        final accessToken = instance.getString('user_token');

                        if (accessToken == null) {
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
                        }

                        setState(() {
                          showLoader = true;
                        });

                        final userResponse = await _api.getByPath(context, 'auth/me');

                        if (userResponse.statusCode == 401) {
                          return Navigator.of(context).pushReplacementNamed('auth/login');
                        }

                        final userData = jsonDecode(userResponse.body);

                        if (userResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/login');
                        }

                        final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

                        if (addressResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/login');
                        }

                        final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

                        if (cardsResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/login');
                        }

                        final cardsData = jsonDecode(cardsResponse.body);

                        final addressData = jsonDecode(addressResponse.body);

                        addressBloc.modifyAddresses(addressData['data']);
                        cardsBloc.modifyCards(cardsData['data']);
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

                        return Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
                      },
                      duration: Duration(seconds: 1),
                      child: SvgPicture.asset('assets/logo-white.svg')
                  ),
                );
              },
            ),
            if (showLoader)
              CircularProgressIndicator()
            else
              SizedBox(height: 38.0)
          ],
        ),
      )
    );
  }
}

