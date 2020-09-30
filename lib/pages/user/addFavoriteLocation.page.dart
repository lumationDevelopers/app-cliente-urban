import 'dart:async';

import 'package:client/credentials.dart';
import 'package:client/pages/user/addFavoriteLocationInfo.page.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class AddFavoriteLocationPage extends StatefulWidget {
  @override
  _AddFavoriteLocationPageState createState() => _AddFavoriteLocationPageState();
}

class _AddFavoriteLocationPageState extends State<AddFavoriteLocationPage> {
  final _scaffoldController = new GlobalKey<ScaffoldState>();
  LatLng location;
  String addressName = 'Unamed Road';

  var searchTimer;

  var _sheetController = new SnappingSheetController();

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

    setState(() {
      location = null;
    });

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

      print(location);
      print(addressName);
    });

  }

  List<dynamic> currentPlaces = [];
  var currentSearchedPlace;
  void searchPlace(String input) {

    if (searchTimer != null) {
      searchTimer.cancel();
    }
    searchTimer = new Timer(Duration(milliseconds: 500), () async {
      Response searchResponse = await Dio().get('$googleAutocompleteUrl?input=$input&key=$googleMapsKey&language=es&components=country:gt');

      setState(() {
        currentPlaces = searchResponse.data['predictions'];
      });
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCurrentLocation();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
                         location == null ? null : () => Navigator.of(context).pushNamed('user/add-favorite-location-info', arguments: AddFavoriteLocationInfoPageArguments(location, addressName))
                  ),
                )
            ),
          ),
          new Positioned(
            child: new Align(
                alignment: FractionalOffset.topRight,
                child: Container(
                  margin: EdgeInsets.only(right: 24.0, bottom: MediaQuery.of(context).padding.bottom + 24.0, top: MediaQuery.of(context).padding.top),
                  child: defaultButton(
                      MediaQuery.of(context).size.width * 0.5,
                      'Buscar ubicación',
                      () {
                        _sheetController.snapToPosition(SnapPosition(positionFactor: 1.0));
                      },
                      color: Colors.white,
                      textColor: Colors.black
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
          SnappingSheet(
            snappingSheetController: _sheetController,
            lockOverflowDrag: true,
            initSnapPosition: SnapPosition(positionFactor: -1.0),
            snapPositions: [
              SnapPosition(positionFactor: -1.0)
            ],
            grabbingHeight: MediaQuery.of(context).padding.bottom + 90,
            grabbing: InkWell(
              onTap: () => FocusManager.instance.primaryFocus.unfocus(),
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.2),
                      )],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22.0),
                        topRight: Radius.circular(22.0),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 50.0,
                          height: 5.0,
                          margin: EdgeInsets.only(top: 15.0),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.all(Radius.circular(5.0))
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 22.0),
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              onChanged: (input) {
                                searchPlace(input);
                              },
                              onTap: () {
                                _sheetController.snapToPosition(SnapPosition(positionFactor: 1));
                              },
                              decoration: InputDecoration(
                                  hintText: '¿A dónde te diriges?'
                              ),
                            )
                        ),
                        Padding(padding: EdgeInsets.only(top: 12.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            sheetBelow: SnappingSheetContent(
              child: Container(
                  padding: EdgeInsets.all(0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(currentPlaces.length > 0 ? 'Resultados' : 'Recientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          )
                      ),
                      Expanded(
                        flex: 30,
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: currentPlaces.length,
                          itemBuilder: (context, index) {
                            return Container(
                                padding: EdgeInsets.all(0),
                                margin: EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();

                                    _sheetController.snapToPosition(SnapPosition(positionFactor: -1.0));

                                    Response detailResponse = await Dio().get('$googleDetailUrl?json&place_id=${currentPlaces[index]['place_id']}&key=$googleMapsKey');

                                    currentSearchedPlace = detailResponse.data['result']['geometry']['location'];
                                    //final currentPosition = await getCurrentPosition();

                                    LatLng searchPosition = LatLng(currentSearchedPlace['lat'], currentSearchedPlace['lng']);

                                    mapController.animateCamera(CameraUpdate.newLatLng(searchPosition));

                                    locationMap(new CameraPosition(target: searchPosition));
                                    //setLocationOnMap(context, searchPosition);
                                  },
                                  child: ListTile(
                                    title: Text(currentPlaces[index]['structured_formatting']['main_text'].toString()),
                                    subtitle: Text(currentPlaces[index]['structured_formatting']['secondary_text'].toString()),
                                  ),
                                )
                            );
                          },
                        ),
                      )
                    ],
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
