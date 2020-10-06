import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../credentials.dart';

class AddWaypointPage extends StatefulWidget {
  @override
  _AddWaypointPageState createState() => _AddWaypointPageState();
}

class _AddWaypointPageState extends State<AddWaypointPage> {
  final _scaffoldController = new GlobalKey<ScaffoldState>();
  LatLng location;
  String addressName = 'Unamed Road';

  var searchTimer;

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    mapController.setMapStyle('[{"elementType": "geometry","stylers":[{"color":"#e6eef4"}]}, {"featureType": "road","elementType": "geometry","stylers":[{"color":"#FFFFFF"}]}]');
  }

  void getCurrentLocation() async {
    final Geolocator location = Geolocator()..forceAndroidLocationManager;
    final position = await location.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print(position);
    CameraUpdate u2 = CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude));
    this.mapController.animateCamera(u2);

    locationMap(CameraPosition(target: LatLng(position.latitude, position.longitude)));
  }

  void locationMap(CameraPosition position) async {

    if (searchTimer != null) {
      searchTimer.cancel();
    }
    searchTimer = new Timer(Duration(milliseconds: 500), () async {
      Response searchResponse = await Dio().get('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.target.latitude},${position.target.longitude}&key=$googleMapsKey');

      if (searchResponse.data['results'].length > 0) {
        setState(() {
          addressName = searchResponse.data['results'][0]['formatted_address'];
        });
      } else {
        setState(() {
          addressName = 'Unamed Road';
        });
      }

      setState(() {
        location = position.target;
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //BackButtonInterceptor.add(myInterceptor);
    getCurrentLocation();
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
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
    return Scaffold(
      key: _scaffoldController,
      body:  Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              //markers: Set<Marker>.of(markers.values),
              myLocationButtonEnabled: false,
              trafficEnabled: false,
              compassEnabled: false,
              buildingsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: _onMapCreated,
              zoomControlsEnabled: false,
              onCameraMove: (v) => locationMap(v),
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                  target: LatLng(14.6166264,-90.5136214),
                  zoom: 13.0
              ),
            ),
          ),
          new Positioned(
            child: new Align(
                alignment: FractionalOffset.center,
                child: Image.asset('assets/rides/origin-lx.png', scale: 1.5)
            ),
          ),
          new Positioned(
            child: new Align(
                alignment: FractionalOffset.bottomRight,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ]
                    ),
                    padding: EdgeInsets.all(6.0),
                    margin: EdgeInsets.only(right: 24.0, bottom: MediaQuery.of(context).padding.bottom + 86.0),
                    child: Material(
                      child: InkWell(
                        onTap: () => getCurrentLocation(),
                        child: Icon(Icons.near_me, size: 48.0),
                      ),
                    )
                )
            ),
          ),
          new Positioned(
            child: new Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(right: 24.0, bottom: MediaQuery.of(context).padding.bottom + 24.0),
                  child: defaultButton(
                      MediaQuery.of(context).size.width * 0.5,
                      'Seleccionar',
                          () => Navigator.of(context).pop()
                  ),
                )
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 20.0),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      width: 56.0,
                      height: 56.0,
                      padding: EdgeInsets.all(8.0),
                      child: SvgPicture.asset('assets/back-icon.svg'),
                    ),
                  ),
                  Spacer(),
                ],
              )
          ),
        ],
      ),
    );
  }
}
