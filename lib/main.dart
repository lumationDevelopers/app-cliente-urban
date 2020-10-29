import 'dart:async';
import 'dart:convert';

import 'package:client/pages/auth/login.page.dart';
import 'package:client/pages/auth/register-addcard.page.dart';
import 'package:client/pages/auth/register-social.page.dart';
import 'package:client/pages/auth/register.page.dart';
import 'package:client/pages/auth/resetPassword.page.dart';
import 'package:client/pages/auth/welcome.page.dart';
import 'package:client/pages/home.page.dart';
import 'package:client/pages/rides/rideChat.page.dart';
import 'package:client/pages/rides/ridePilotInfo.page.dart';
import 'package:client/pages/user/addFavoriteLocation.page.dart';
import 'package:client/pages/user/addFavoriteLocationInfo.page.dart';
import 'package:client/pages/user/addPaymentMethod.page.dart';
import 'package:client/pages/user/addWaypoint.page.dart';
import 'package:client/pages/user/changeEmail.page.dart';
import 'package:client/pages/user/changeGender.page.dart';
import 'package:client/pages/user/changePasswordStep2.page.dart';
import 'package:client/pages/user/changePersonalInfo.page.dart';
import 'package:client/pages/user/changePhoneNumber.page.dart';
import 'package:client/pages/user/chargePasswordStep1.page.dart';
import 'package:client/pages/user/contactUs.page.dart';
import 'package:client/pages/user/favoriteLocationDetail.page.dart';
import 'package:client/pages/user/favoriteLocations.page.dart';
import 'package:client/pages/user/paymentMethodSelect.page.dart';
import 'package:client/pages/user/paymentMethods.page.dart';
import 'package:client/pages/user/paymentMethodsDetail.page.dart';
import 'package:client/pages/user/privacy.page.dart';
import 'package:client/pages/user/privacyOptions.page.dart';
import 'package:client/pages/user/profile.page.dart';
import 'package:client/pages/user/ridesHistory.page.dart';
import 'package:client/pages/user/ridesHistoryDetail.page.dart';
import 'package:client/pages/user/scheduledRide.page.dart';
import 'package:client/pages/user/scheduledRideDetail.page.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Urban Taxi',
        home: StartPage(),
        //routes: routes,
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
            case '':
              return CupertinoPageRoute(
                  builder: (_) => StartPage(), settings: settings);
            case '/home':
              return CupertinoPageRoute(
                  builder: (_) => HomePage(), settings: settings);
            case 'user/settings':
              return CupertinoPageRoute(
                  builder: (_) => SettingsPage(), settings: settings);
            case 'auth/welcome':
              return CupertinoPageRoute(
                  builder: (_) => WelcomePage(), settings: settings);
            case 'auth/login':
              return CupertinoPageRoute(
                  builder: (_) => LoginPage(), settings: settings);
            case 'auth/reset-password':
              return CupertinoPageRoute(
                  builder: (_) => ResetPasswordPage(), settings: settings);
            case 'auth/register':
              return CupertinoPageRoute(
                  builder: (_) => RegisterPage(), settings: settings);
            case 'auth/register/social':
              return CupertinoPageRoute(
                  builder: (_) => RegisterSocialPage(), settings: settings);
            case 'auth/register/card':
              return CupertinoPageRoute(
                  builder: (_) => RegisterAddCardPage(), settings: settings);
            case 'user/rides-history':
              return CupertinoPageRoute(
                  builder: (_) => RidesHistoryPage(), settings: settings);
            case 'user/rides-history-detail':
              return CupertinoPageRoute(
                  builder: (_) => RidesHistoryDetailPage(), settings: settings);
            case 'user/scheduled-rides':
              return CupertinoPageRoute(
                  builder: (_) => ScheduledRidesPage(), settings: settings);
            case 'user/scheduled-rides-detail':
              return CupertinoPageRoute(
                  builder: (_) => ScheduledRideDetailPage(), settings: settings);
            case 'user/add-payment-methods':
              return CupertinoPageRoute(
                  builder: (_) => AddPaymentMethodPage(), settings: settings);
            case 'user/payment-methods':
              return CupertinoPageRoute(
                  builder: (_) => PaymentMethodsPage(), settings: settings);
            case 'user/payment-methods-detail':
              return CupertinoPageRoute(
                  builder: (_) => PaymentMethodsDetailPage(), settings: settings);
            case 'user/payment-methods-select':
              return CupertinoPageRoute(
                  builder: (_) => PaymentMethodSelectPage(), settings: settings);
            case 'user/change-password-1':
              return CupertinoPageRoute(
                  builder: (_) => ChangePasswordStep1Page(), settings: settings);
            case 'user/change-password-2':
              return CupertinoPageRoute(
                  builder: (_) => ChangePasswordStep2Page(), settings: settings);
            case 'user/phone-number':
              return CupertinoPageRoute(
                  builder: (_) => ChangePhoneNumberPage(), settings: settings);
            case 'user/gender':
              return CupertinoPageRoute(
                  builder: (_) => ChangeGenderPage(), settings: settings);
            case 'user/contact-us':
              return CupertinoPageRoute(
                  builder: (_) => ContactUsPage(), settings: settings);
            case 'user/email':
              return CupertinoPageRoute(
                  builder: (_) => ChangeEmailPage(), settings: settings);
            case 'user/personal-info':
              return CupertinoPageRoute(
                  builder: (_) => ChangePersonalInfoPage(), settings: settings);
            case 'user/privacy':
              return CupertinoPageRoute(
                  builder: (_) => PrivacyPage(), settings: settings);
            case 'user/privacy-options':
              return CupertinoPageRoute(
                  builder: (_) => PrivacyOptionsPage(), settings: settings);
            case 'user/favorite-locations':
              return CupertinoPageRoute(
                  builder: (_) => FavoriteLocationsPage(), settings: settings);
            case 'user/favorite-location-detail':
              return CupertinoPageRoute(
                  builder: (_) => FavoriteLocationDetailPage(), settings: settings);
            case 'user/add-favorite-location':
              return CupertinoPageRoute(
                  builder: (_) => AddFavoriteLocationPage(), settings: settings);
            case 'user/add-favorite-location-info':
              return CupertinoPageRoute(
                  builder: (_) => AddFavoriteLocationInfoPage(), settings: settings);
            case 'ride/pilot-selected':
              return CupertinoPageRoute(
                  builder: (_) => RidePilotInfoPage(), settings: settings);
            case 'ride/chat':
              return CupertinoPageRoute(
                  builder: (_) => RideChatPage(), settings: settings);
            case 'ride/add-waypoint':
              return CupertinoPageRoute(
                  builder: (_) => AddWaypointPage(), settings: settings);
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

  Future initPlatformState() async {

    await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

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

    await OneSignal.shared.setSubscription(true);

    return true;

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
                        await initPlatformState();
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
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
                        }

                        final userData = jsonDecode(userResponse.body);

                        if (userResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
                        }

                        final addressResponse = await _api.getByPath(context, 'address/all/${userData['data']['user']['_id']}');

                        if (addressResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
                        }

                        final cardsResponse = await _api.getByPath(context, 'cards/owncards/${userData['data']['user']['_id']}');

                        if (cardsResponse.statusCode != 200) {
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
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
                          return Navigator.of(context).pushReplacementNamed('auth/welcome');
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

