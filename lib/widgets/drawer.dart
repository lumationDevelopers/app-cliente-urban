import 'dart:convert';

import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/user/ridesHistory.page.dart';
import 'package:client/pages/user/scheduledRide.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/cupertino.dart';


appDrawer(BuildContext context) {
  final bloc = Provider.of(context).userBloc;

  return Theme(
    data: Theme.of(context).copyWith(
      canvasColor: Colors.black,
      accentColor: Colors.white,
      textTheme: TextTheme(
        bodyText1: TextStyle(color: Colors.white)
      )
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(32.0),
        bottomRight: Radius.circular(32.0)
      ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 152.0,
              width: double.infinity,
              padding: EdgeInsets.only(top: 64.0),
              child: ListTile(
                leading: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(42.0),
                    child: StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.data == null || snapshot.data['avatar'] == null) {
                          return Icon(Icons.person_outline, size: 42.0, color: Colors.white);
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
                title: StreamBuilder(
                  stream: bloc.userStream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Text('${snapshot.data['name']} ${snapshot.data['lastname']}', style: TextStyle(fontSize: 20.0));
                    } else {
                      return Text('');
                    }
                  },
                ),
                subtitle: Row(
                  children: <Widget>[
                    Icon(Icons.star, color: Colors.white),
                    StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.data != null && bloc.userInfo['rating'] != null) {
                          return Text(bloc.userInfo['rating'] != null ? bloc.userInfo['rating'].toStringAsFixed(2) : '0.00', style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-light'));
                        } else {
                          return Text('0.00', style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-light'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-person.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Perfil', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {
                Navigator.of(context).popAndPushNamed('user/profile');
              },
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-history.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Historial de viajes', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {
                Navigator.of(context).popAndPushNamed('user/rides-history', arguments: RidesHistoryArguments(bloc.userInfo['_id']));
              },
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-calendar.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Viajes programados', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {
                Navigator.of(context).popAndPushNamed('user/scheduled-rides', arguments: ScheduledRideArguments(bloc.userInfo['_id']));
              },
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-person.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Métodos de pago', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {
                Navigator.of(context).popAndPushNamed('user/payment-methods');
              },
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-help.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Preguntas frecuentes', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {

              },
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-phone.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Contáctanos', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () => Navigator.of(context).pushNamed('user/contact-us'),
            ),
            ListTile(
              leading: Container(
                width: 38.0,
                alignment: Alignment.center,
                child: SvgPicture.asset('assets/icon-settings.svg', color: Colors.white, width: 24.0,),
              ),
              title: Text('Configuración', style: TextStyle(fontFamily: 'Lato-light', fontSize: 18.0)),
              onTap: () {
                Navigator.of(context).popAndPushNamed('user/settings');
              },
            ),
          ],
        ),
      ),
    )
  );
}