import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/address.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/user/favoriteLocationDetail.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';

class FavoriteLocationsPage extends StatefulWidget {
  @override
  _FavoriteLocationsPageState createState() => _FavoriteLocationsPageState();
}

class _FavoriteLocationsPageState extends State<FavoriteLocationsPage> with AfterInitMixin<FavoriteLocationsPage> {
  List<dynamic> rides = [];

  final _api = new Api();
  final _utils = new Utils();

  @override
  void didInitState() {
    //getData(addressBloc);
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
    final addressBloc = Provider.of(context).addressBloc;

    return Scaffold(
        appBar: urbanAppBar(context, 'Direcciones favoritas', true),
        body: StreamBuilder(
          stream: addressBloc.addressStream,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Stack(
                children: <Widget>[
                  if (snapshot.data.length > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                                    padding: EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 5,
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ]
                                    ),
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pushNamed('user/favorite-location-detail', arguments: FavoriteLocationDetailArguments(snapshot.data[index])),
                                      child: ListTile(
                                        title: Container(
                                          child: Text('${snapshot.data[index]['address_name']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0)),
                                        ),
                                        subtitle: Text(snapshot.data[index]['address']),
                                      ),
                                    )
                                );
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(24.0),
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () => Navigator.of(context).pushNamed('user/add-favorite-location'),
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.add_circle_outline, size: 50.0),
                                  Text("Agregar dirección favorita", style: TextStyle(fontSize: 20.0, fontFamily: 'Lato-Light'),)
                                ],
                              ),
                            )
                          ),
                        )
                      ],
                    ),
                  if (snapshot.data.length < 1)
                    Container(
                      padding: EdgeInsets.all(32.0),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.star, size: MediaQuery.of(context).size.width * 0.4),
                          Padding(padding: EdgeInsets.only(top: 42.0)),
                          Text('No tienes ninguna dirección favorita', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                          Padding(padding: EdgeInsets.only(top: 12.0)),
                          InkWell(
                            onTap: () => Navigator.of(context).pushNamed('user/add-favorite-location'),
                            child: Container(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                children: <Widget>[
                                  Icon(Icons.add_circle_outline, size: 50.0),
                                  Text("Agregar dirección favorita", style: TextStyle(fontSize: 20.0, fontFamily: 'Lato-Light'),)
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                ],
              );
            } else {
              return Text('');
            }

          },
        )
    );
  }
}
