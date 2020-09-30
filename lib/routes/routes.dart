import 'package:client/main.dart';
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
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  '' : (BuildContext context) => StartPage(),
  'auth/welcome' : (BuildContext context) => WelcomePage(),
  'auth/login': (BuildContext context) => LoginPage(),
  'auth/reset-password': (BuildContext context) => ResetPasswordPage(),
  'auth/register': (BuildContext context) => RegisterPage(),
  'auth/register/social': (BuildContext context) => RegisterSocialPage(),
  'auth/register/card': (BuildContext context) => RegisterAddCardPage(),
  '/home': (BuildContext context) => HomePage(),
  'user/rides-history': (BuildContext context) => RidesHistoryPage(),
  'user/rides-history-detail': (BuildContext context) => RidesHistoryDetailPage(),
  'user/scheduled-rides': (BuildContext context) => ScheduledRidesPage(),
  'user/scheduled-rides-detail': (BuildContext context) => ScheduledRideDetailPage(),
  'user/add-payment-methods': (BuildContext context) => AddPaymentMethodPage(),
  'user/payment-methods': (BuildContext context) => PaymentMethodsPage(),
  'user/payment-methods-detail': (BuildContext context) => PaymentMethodsDetailPage(),
  'user/payment-methods-select': (BuildContext context) => PaymentMethodSelectPage(),
  //'user/settings': (BuildContext context) => SettingsPage(),
  //'user/profile': (BuildContext context) => ProfilePage(),
  'user/change-password-1': (BuildContext context) => ChangePasswordStep1Page(),
  'user/change-password-2': (BuildContext context) => ChangePasswordStep2Page(),
  'user/phone-number': (BuildContext context) => ChangePhoneNumberPage(),
  'user/gender': (BuildContext context) => ChangeGenderPage(),
  'user/contact-us': (BuildContext context) => ContactUsPage(),
  'user/email': (BuildContext context) => ChangeEmailPage(),
  'user/personal-info': (BuildContext context) => ChangePersonalInfoPage(),
  'user/privacy': (BuildContext context) => PrivacyPage(),
  'user/privacy-options': (BuildContext context) => PrivacyOptionsPage(),
  'user/favorite-locations': (BuildContext context) => FavoriteLocationsPage(),
  'user/add-favorite-location': (BuildContext context) => AddFavoriteLocationPage(),
  'user/add-favorite-location-info': (BuildContext context) => AddFavoriteLocationInfoPage(),
  'ride/pilot-selected': (BuildContext context) => RidePilotInfoPage(),
  'ride/chat': (BuildContext context) => RideChatPage(),
  'ride/add-waypoint': (BuildContext context) => AddWaypointPage(),
};