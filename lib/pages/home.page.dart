import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/chat.bloc.dart';
import 'package:client/bloc/chatSocket.bloc.dart';
import 'package:client/bloc/paymentMethodSelected.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/bloc/ride.bloc.dart';
import 'package:client/bloc/rideStatus.bloc.dart';
import 'package:client/bloc/user.bloc.dart';
import 'package:client/credentials.dart';
import 'package:client/pages/rides/ridePilotInfo.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:client/widgets/drawer.dart';
import 'package:dio/dio.dart';
import 'package:fade/fade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin, AfterInitMixin<HomePage> {
  final _formGender = GlobalKey<FormState>();
  var _requestedGender;
  bool requestGender = false;

  final Utils _utils = new Utils();

  Timer _getInfoTimer;

  double _driverRating = 0;
  String _driverComment = '';

  bool lookingForPilot = false;
  bool noPilots = false;

  bool onRide = false;
  bool driverOnLocation = false;
  bool rateDriver = false;
  String estimatedTime = '0 mins';
  DateTime scheduledRide;
  var driverArrival = false;
  var driverArrivalMessageDisplayed = false;
  bool showDriverLocation = true;

  double grabbingHeight;
  final _api = new Api();

  bool addingNewPoint = false;

  TimerController _timerController;

  final utils = new Utils();

  var _sheetController = new SnappingSheetController();
  var statusBarColor = Colors.transparent;
  bool searchFormVisible = false;

  var estimateDistance = '0';

  var placeSelected;
  var placePositionSelected;

  int currentInputSearch = 2;
  LatLng _center = LatLng(14.636787,-90.5134347);
  double _centerAngle = 0.00;
  double mapZoom = 16.0;
  double mapScaleHeight = 1;

  List urbanServices = [];

  final _scaffoldController = new GlobalKey<ScaffoldState>();

  Timer searchTimer;

  GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    mapController.setMapStyle('[{"elementType": "geometry","stylers":[{"color":"#e6eef4"}]}, {"featureType": "road","elementType": "geometry","stylers":[{"color":"#FFFFFF"}]}]');

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

  Future<dynamic> getRouteCoordinates(LatLng l1, LatLng l2, { LatLng waypoint }) async {
    Response directionResponse;

    if (waypoint != null) {
      print('hay waypoint');
      directionResponse = await Dio().get('https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&waypoints=via:${waypoint.latitude}%2C${waypoint.longitude}&key=$googleMapsKey');
    } else {
      directionResponse = await Dio().get('https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$googleMapsKey');
    }


    _addMarker(l1, 'start', 'assets/rides/origin-lx.png');
    _addMarker(l2, 'end', 'assets/rides/destination-lx.png');

    if (waypoint != null) {
      print('waypoint marker');
      _addMarker(waypoint, 'waypoint', 'assets/rides/origin-lx.png');
    }

    print(directionResponse);

    return directionResponse.data["routes"][0];
  }

  Map<PolylineId, Polyline> _polyLines = {};
  Map<PolylineId, Polyline> get polyLines => _polyLines;

  bool showUrbanServices = false;

  void createRoute(String encondedPoly) {
    setState(() {
      _polyLines = {};
    });

    final PolylineId polylineId = PolylineId('newride');
    final polyLine = Polyline(
        polylineId: polylineId,
        width: 5,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.black);

    setState(() {
      _polyLines[polylineId] = polyLine;
    });

  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      }
      while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);
    for (var i = 2; i < lList.length; i++)
      lList[i] += lList[i - 2];
    return lList;
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  void _addMarker(LatLng position, String markId, String iconPath) async {

    final image = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), iconPath);

    final MarkerId markerId = MarkerId(markId);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      icon: image,
      draggable: false,
      flat: true,
      anchor: const Offset(0.5, 0.5)
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  getLocationByPlaceId() async {

    if (currentSearchedPlace == null) {
      Response detailResponse = await Dio().get('$googleDetailUrl?json&place_id=${placeSelected['place_id']}&key=$googleMapsKey');

      currentSearchedPlace = detailResponse.data['result']['geometry']['location'];
      //final currentPosition = await getCurrentPosition();

      LatLng searchPosition = LatLng(currentSearchedPlace['lat'], currentSearchedPlace['lng']);
      setLocationOnMap(context, searchPosition);
    } else {
      setLocationOnMap(context, LatLng(currentSearchedPlace['lat'], currentSearchedPlace['lng']));
    }


  }

  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    _getInfoTimer.cancel();
  }

  bool searchListIsOpen = false;
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (searchListIsOpen) {
      _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
      FocusManager.instance.primaryFocus.unfocus();
      searchListIsOpen = false;
      return true;
    } else {
      //Navigator.of(context).pop();
      return false;
    }

  }

  Future<Position> getCurrentPosition() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    final position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }

  Future getUrbanServices() async {
    final response = await _api.getByPath(context, 'services');

  }

  var _socket;

  void setLocationOnMap(BuildContext context, LatLng destination, { LatLng waypoint }) async {
    //_sheetController.snapToPosition(SnapPosition(positionFactor: -0.4));

    utils.loadingDialog(context);

    final response = await _api.getByPath(context, 'services');

    final data = jsonDecode(response.body);
    if (data['success'] == false) {
      return utils.messageDialog(context, 'Error', 'Hubo un error al cargar los servicios de urban');
    }

    data['data'][0]['selected'] = true;

    setState(() {
      urbanServices = data['data'];
    });


    dynamic routeCoordinates;

    if (waypoint != null) {
      routeCoordinates = await getRouteCoordinates(_center, destination, waypoint: waypoint);
    } else {
      routeCoordinates = await getRouteCoordinates(_center, destination);
    }

    //final routeCoordinates = await getRouteCoordinates(LatLng(currentSearchedPlace['latitude'], currentSearchedPlace['longitude']), LatLng(currentPosition.latitude, currentPosition.longitude));
    createRoute(routeCoordinates["overview_polyline"]["points"]);

    urbanServices.forEach((e) async {

      Map data = {
        "initial_coordinate": "${_center.latitude},${_center.longitude}",
        "final_coordinate": "${destination.latitude},${destination.longitude}",
        "stops": [],
        "total_distance": routeCoordinates['legs'][0]['distance']['value'] / 1000,
        "total_time": routeCoordinates['legs'][0]['duration']['value'] / 60
      };

      if (waypoint != null) {
        data['stops'] = ["${waypoint.latitude},${waypoint.longitude}"];
      }

      final priceResponse = await _api.postByPath(context, 'trips/estimateprice', data);

      final priceData = jsonDecode(priceResponse.body);


      setState(() {
        e['price'] = priceData['data']['total_trip_fare'];
        e['distance'] = priceData['data']['distance'];
        e['duration'] = priceData['data']['duration'];
      });

    });

    if (bloc.userInfo['gender'] == false) {
      urbanServices.removeWhere((e) => e['service_name'] == 'Urban Pink');
    }

    setState(() {
      showUrbanServices = true;
      grabbingHeight = MediaQuery.of(context).padding.bottom + 340;
    });

    _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));

    LatLngBounds bound = boundsFromLatLngList([_center, destination]);
    double distance;

    /*if (destination.latitude > _center.latitude) {
      distance = 120;
      bound = LatLngBounds(southwest: _center, northeast: destination);
    } else {
      distance = 140;
      bound = LatLngBounds(southwest: destination, northeast: _center );
    }*/


    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 120);

    this.mapController.animateCamera(u2);

    setState(() {
      mapScaleHeight = 0.65;
    });

    utils.closeDialog(context);
  }

  bool rideAccepted = false;
  var _socketTrips;
  LatLng _onRideLocation;
  void startRide(String rideId) async {
    final storage = await SharedPreferences.getInstance();
    _socketTrips = IO.io('$socketUri/trips?token=${storage.getString('user_token')}&trip=$rideId', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socketTrips.connect();

    _socketTrips.on('connect', (v) {
      print(_socketTrips.connected);
    });

    _socketTrips.on('driverlocation', (v) async {
      print(v);

      if (rideAccepted == true) {
        final MarkerId markerId = MarkerId('curren_loc');
        final icon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'assets/rides/car-icon.png');
        setState(() {
          if (v['location']['lat'] != null && v['location']['lat'] != '') {
            markers.remove(markerId);
            Marker resultMarker = Marker(
              markerId: MarkerId('curren_loc'),
              icon: icon,
              rotation: _centerAngle,
              position: LatLng(v['location']['lat'], v['location']['lon']),
            );
            _onRideLocation = LatLng(v['location']['lat'], v['location']['lon']);
            markers[markerId] = resultMarker;
          }
          if (v['estimated_time'] != null ) {
            estimatedTime = v['estimated_time'];
          }

          if (v['driverArrival'] == true) {
            driverArrival = true;
          }

          lookingForPilot = false;
        });

        if (v['status'] == 'Available') {
          rideStatusBloc.modifyRideStatus('Started');
        } else {
          rideStatusBloc.modifyRideStatus(v['status']);
        }



        if (showDriverLocation = true) {
          setState(() {
            showDriverLocation = false;
          });

          mapDriverLocation(LatLng(v['location']['lat'], v['location']['lon']));
        }

        if (v['status'] == 'Canceled') {
          utils.messageDialog(context, 'Viaje cancelado', 'EL piloto cancelo el viaje');

          setState(() {
            _polyLines = {};
            markers = {};
            mapScaleHeight = 1.0;
            currentWaypointLocation = null;
          });

          mapUserLocation();

          _sheetController.snapToPosition(SnapPosition(positionFactor: -1, snappingDuration: Duration(seconds: 2)));

          new Timer(Duration(seconds: 2), () {
            setState(() {
              showUrbanServices = false;
            });
            _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
          });
        }
      }

      if (v['status'] == 'Finished') {
        _socketTrips.disconnect();
      }


      if (v['is_accepted'] == false) {
        setState(() {
          rideAccepted = false;
        });

        getUserInfo(connectToSockets: false);
      }

      if (v['is_accepted'] == true || v['status'] == 'Passenger onboard' || v['status'] == 'Waiting') {
        setState(() {
          rideAccepted = true;
        });
      }
    });
  }

  void mapDriverLocation(LatLng location) {
    CameraUpdate u2 = CameraUpdate.newLatLngZoom(location, 17.0);

    mapController.animateCamera(u2);

    Timer(Duration(seconds: 2), () {
      setState(() {
        showDriverLocation = true;
      });
    });

  }

  void confirmRide(BuildContext context) async {
    setState(() {
      lookingForPilot = true;
      mapScaleHeight = 1.0;
    });

    await new Future.delayed(const Duration(seconds: 2), () => "1");

    setState(() {
      showUrbanServices = false;
    });
    final service = urbanServices.firstWhere((element) => element['selected'] == true);

    final data = {
      "service": {
        "id": service['_id']
      },
      "payment_method": {
        "id": paymentMethodSelectedBloc.paymentMethodSelect['_id']
      },
      "pickup": {
        "zone": "-",
        "address": _userCurrentPositionAddress,
        "type": "Point",
        "coordinates": "${_center.latitude},${_center.longitude}"
      },
      "destination": {
        "zone": "-",
        "address": placeSelected['description'],
        "type": "Point",
        "coordinates": "${currentSearchedPlace['lat']},${currentSearchedPlace['lng']}"
      },
      "stops": [],
      "contact_form": {
        "id": "5eeaa745189c16383c457cf9"
      },
      "distance_estimate": service['distance'],
      "time_estimate": service['duration'],
      "scheduled": scheduledRide == null ? false : true,
      "fare": service['price'],
    };

    if (paymentMethodSelectedBloc.paymentMethodSelect['name'] == 'tarjeta') {
      data['card'] = {
        'id': paymentMethodSelectedBloc.paymentMethodSelect['card']
      };
    }

    if(scheduledRide != null) {
      data['pickup_time'] = (new DateFormat('dd/MM/yyyy HH:mm').format(scheduledRide)).toString();
    }

    if (currentWaypointLocation != null) {
      data['stops'] = [
        {
          "zone": "-",
          "address": currentWaypointAddress,
          "type": "Point",
          "coordinates": "${currentWaypointLocation.latitude},${currentWaypointLocation.longitude}"
        }
      ];
    }

    var rideResponse;

    if (scheduledRide == null) {
      rideResponse = await _api.postByPath(context, 'trips/newtrip', data);
    } else {
      rideResponse = await _api.postByPath(context, 'trips/newscheduledtrip', data);
    }

    final rideData = jsonDecode(rideResponse.body);

    if (rideData['success'] == false) {
      setState(() {
        mapScaleHeight = 1.0;
        _polyLines = {};
        markers = {};
        showUrbanServices = false;
        lookingForPilot = false;
      });



      _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));

      if (rideData['error']['errors'][0] == 'No se encontro ningun piloto') {
        return setState(() {
          noPilots = true;
        });
      }

      setState(() {
        _polyLines = {};
        markers = {};
        mapScaleHeight = 1.0;
      });

      print(rideResponse.body);

      return utils.messageDialog(context, 'Viaje no confirmado', 'Hubo algún error. Inténtalo de nuevo.');
    }

    if (scheduledRide != null) {
      setState(() {
        lookingForPilot = false;
        _polyLines = {};
        markers = {};
        mapScaleHeight = 1.0;
        showUrbanServices = false;
      });

      rideStatusBloc.modifyRideStatus('Pending');
      _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));

      return utils.messageDialog(context, 'Solicitado', 'Se ha solicitado un viaje programado. Un piloto llegará a la hora indicada');
    }

    scheduledRide = null;


    rideBloc.modifyRideData(rideData['data']);

    rideStatusBloc.modifyRideStatus('Started');

    setState(() {
      mapScaleHeight = 1.0;
      //_polyLines = {};
      //markers = {};
      showUrbanServices = false;
      onRide = true;
    });

    rideBloc.modifyRideData(rideData['data']);

    startChat(rideData['data']);

    startRide(rideData['data']['_id']);

    _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
  }

  String _userCurrentPositionAddress = '';
  void mapUserLocation() async {
    final icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), 'assets/rides/origin-lx.png');
    getCurrentPosition().then((Position position) async {
      final MarkerId markerId = MarkerId('start');
      Marker resultMarker = Marker(
        markerId: MarkerId('start'),
        icon: icon,
        position: LatLng(position.latitude, position.longitude),
      );
      setState(() {
        markers[markerId] = resultMarker;
        _center = LatLng(position.latitude, position.longitude);
        _centerAngle = position.heading;
      });

      CameraUpdate u2 = CameraUpdate.newLatLngZoom(_center, 17.0);
      mapController.animateCamera(u2);

      Response searchResponse = await Dio().get('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapsKey');

      if (searchResponse.data['results'].length > 0) {
        setState(() {
          _userCurrentPositionAddress = searchResponse.data['results'][0]['formatted_address'];;

        });
      } else {
        setState(() {
          _userCurrentPositionAddress = "Unamed Road";

        });
      }
    });

  }

  UserBloc bloc;
  ChatBloc chatBloc;
  ChatSocketBloc chatSocketBloc;
  RideStatusBloc rideStatusBloc;
  RideBloc rideBloc;
  PaymentMethodSelectedBloc paymentMethodSelectedBloc;
  void startChat(ride) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    _socket = IO.io('$socketUri/chats?token=${storage.getString('user_token')}', <String, dynamic>{
      'transports': ['websocket'],
    });

    chatSocketBloc.modifySocket(_socket);

    _socket.connect();
    _socket.on('connect', (_) {
      if (!_socket.connected) {
        return startChat(ride);
      }
      _socket.emit('joinchat', {
        "displayname": bloc.userInfo['username'],
        "user": ride['user']['_id'],
        "trip": ride['_id']
      });
    });

    _socket.on('message', (value) {
      if (chatBloc.messages != null) {
        chatBloc.modifyMessages([...chatBloc.messages,
          {
            "username": value['username'],
            "text": value['text'],
            "time": value['time']
          }
        ]);
      } else {
        chatBloc.modifyMessages([
          {
            "username": value['username'],
            "text": value['text'],
            "time": value['time']
          }
        ]);
      }

    });


    _socket.on('event', (data) => print('sdsds' + jsonDecode(data)));
    _socket.on('disconnect', (_) => print('chat disconnected'));
    _socket.on('fromServer', (_) => print('asdsdsd' + jsonDecode(_)));
  }

  bool waypointIsOrigin = false;
  bool waypointIsDestination = false;
  List waypoints;
  String currentWaypointAddress;
  LatLng currentWaypointLocation;
  CameraPosition mapWaypointPosition;
  String currentPlaceId = '';

  Future locationMap() async {

      Response searchResponse = await Dio().get('https://maps.googleapis.com/maps/api/geocode/json?latlng=${mapWaypointPosition.target.latitude},${mapWaypointPosition.target.longitude}&key=$googleMapsKey');

      if (searchResponse.data['results'].length > 0) {
        if (!waypointIsOrigin) {
          setState(() {
            currentWaypointAddress = searchResponse.data['results'][0]['formatted_address'];
            currentWaypointLocation = LatLng(mapWaypointPosition.target.latitude, mapWaypointPosition.target.longitude);
            /*waypoints.add({
            "address": searchResponse.data['results'][0]['formatted_address'],
            "location": [, ]
          });*/
          });

          if (waypointIsDestination) {
            setState(() {
              placeSelected['description'] = searchResponse.data['results'][0]['formatted_address'];
              currentSearchedPlace = {
                "lat": mapWaypointPosition.target.latitude,
                "lng": mapWaypointPosition.target.longitude
              };
              /*waypoints.add({
            "address": searchResponse.data['results'][0]['formatted_address'],
            "location": [, ]
          });*/
            });
            //getLocationByPlaceId();

          }
        } else {
            setState(() {
              _userCurrentPositionAddress = searchResponse.data['results'][0]['formatted_address'];
              _center = LatLng(mapWaypointPosition.target.latitude, mapWaypointPosition.target.longitude);
              /*waypoints.add({
            "address": searchResponse.data['results'][0]['formatted_address'],
            "location": [, ]
          });*/
            });


          getLocationByPlaceId();
        }

      } else {
        if (!waypointIsOrigin) {
          setState(() {
            currentWaypointAddress = "Unamed Road";
            currentWaypointLocation = LatLng(mapWaypointPosition.target.latitude, mapWaypointPosition.target.longitude);
            /*waypoints.add({
            "address": "Unamed Road",
            "location": [position.target.latitude, position.target.longitude]
          });*/
          });

          if (waypointIsDestination) {
            setState(() {
              placeSelected['description'] = "Unamed Road";
              currentSearchedPlace = {
                "lat": mapWaypointPosition.target.latitude,
                "lng": mapWaypointPosition.target.longitude
              };
              /*waypoints.add({
            "address": searchResponse.data['results'][0]['formatted_address'],
            "location": [, ]
          });*/
            });
            //getLocationByPlaceId();

          }
        } else {
          setState(() {
            _userCurrentPositionAddress = "Unamed Road";
            _center = LatLng(mapWaypointPosition.target.latitude, mapWaypointPosition.target.longitude);
            /*waypoints.add({
            "address": "Unamed Road",
            "location": [position.target.latitude, position.target.longitude]
          });*/
          });
          getLocationByPlaceId();
        }

      }

      return 0;

  }


  @override
  void didInitState() {
    // TODO: implement didInitState

      mapUserLocation();
      getUserInfo();
      _getInfoTimer = Timer.periodic(Duration(minutes: 2), (timer) {
        getUserInfo();
      });
    /*if (rideStatusBloc.rideStatus != 'Pending') {
      startChat(rideBloc.rideInfo);
      startRide(rideBloc.rideInfo['_id']);
    }*/
  }


  getUserInfo({ bool connectToSockets = true}) async {
    final userResponse = await _api.getByPath(context, 'auth/me');

    if ((bloc.userInfo['request_gender'] != null && bloc.userInfo['request_gender'] == true) || bloc.userInfo['gender'] == null) {
      setState(() {
        requestGender = true;
      });
    }

    if (userResponse.statusCode == 401) {
      return Navigator.of(context).pushReplacementNamed('auth/login');
    }

    final userData = jsonDecode(userResponse.body);

    if (userData['data']['user']['current_trip'] != null && !onRide) {

      final rideResponse = await _api.getByPath(context, 'trips/${userData['data']['user']['current_trip']}');

      if (rideResponse.statusCode != 200) {
        rideStatusBloc.modifyRideStatus('Pending');
        return Navigator.of(context).pushReplacementNamed('auth/login');
      }

      final rideData = jsonDecode(rideResponse.body);

      setState(() {
        rideAccepted = true;
      });

      rideBloc.modifyRideData(rideData['data']);
      print(rideData['data']['trip_status']);
      if (rideData['data']['trip_status'] == 'Created') {
        rideStatusBloc.modifyRideStatus('Started');
      } else {
        rideStatusBloc.modifyRideStatus(rideData['data']['trip_status']);
      }


      setState(() {
        onRide = true;
      });

      if (connectToSockets) {
        startChat(rideData['data']);
        startRide(rideData['data']['_id']);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    bloc = Provider.of(context).userBloc;
    rideBloc = Provider.of(context).rideBloc;
    final addressBloc = Provider.of(context).addressBloc;
    chatBloc = Provider.of(context).chatBloc;
    chatSocketBloc = Provider.of(context).chatSocketBloc;
    rideStatusBloc = Provider.of(context).rideStatusBloc;
    paymentMethodSelectedBloc = Provider.of(context).paymentMethodSelectedBloc;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent
      ),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldController,
        drawer: appDrawer(context),
        body: StreamBuilder(
          stream: rideBloc.rideStream,
          builder: (context, rideSnapshot) {
            return StreamBuilder(
              stream: rideStatusBloc.rideStatusStream,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * mapScaleHeight,
                        child: GoogleMap(
                          markers: Set<Marker>.of(markers.values),
                          polylines: Set<Polyline>.of(_polyLines.values),
                          myLocationButtonEnabled: false,
                          trafficEnabled: false,
                          compassEnabled: false,
                          buildingsEnabled: false,
                          mapToolbarEnabled: false,
                          onMapCreated: _onMapCreated,
                          zoomControlsEnabled: false,
                          onCameraMove: (v) {
                            setState(() {
                              mapWaypointPosition = v;
                            });
                          },
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                              target: _center,
                              zoom: mapZoom
                          ),
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
                                margin: EdgeInsets.only(right: 24.0, bottom: MediaQuery.of(context).padding.bottom + 206.0),
                                child: Material(
                                  child: InkWell(
                                    onTap: () => mapUserLocation(),
                                    child: Icon(Icons.gps_fixed, size: 40.0),
                                  ),
                                )
                            )
                        ),
                      ),
                      if (!addingNewPoint)
                        Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 20.0),
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: () => _scaffoldController.currentState.openDrawer(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    width: 46.0,
                                    height: 46.0,
                                    padding: EdgeInsets.all(8.0),
                                    child: SvgPicture.asset('assets/icon-menu.svg'),
                                  ),
                                ),
                                Spacer(),
                              ],
                            )
                        ),
                      if (addingNewPoint && !waypointIsOrigin)
                        Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 20.0),
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: () {

                                    setState(() {
                                      addingNewPoint = false;
                                      mapScaleHeight = 0.6;
                                      showUrbanServices = true;
                                    });

                                    _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 14.0),
                                    child: SvgPicture.asset('assets/back-icon.svg', color: Colors.black,),
                                  ),
                                ),
                                Spacer(),
                              ],
                            )
                        ),
                      if (addingNewPoint)
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
                      if (!showUrbanServices && !addingNewPoint && (snapshot.data == 'Pending' || snapshot.data == 'Finished' || snapshot.data == 'Cancelled'))
                        SnappingSheet(
                          snappingSheetController: _sheetController,
                          lockOverflowDrag: true,
                          snapPositions: [
                            SnapPosition(positionFactor: 0.0)
                          ],
                          grabbingHeight: MediaQuery.of(context).padding.bottom + 180,
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
                                              searchListIsOpen = true;
                                              _sheetController.snapToPosition(SnapPosition(positionFactor: 1));
                                            },
                                            decoration: InputDecoration(
                                                hintText: '¿A dónde te diriges?'
                                            ),
                                          )
                                      ),
                                      Padding(padding: EdgeInsets.only(top: 12.0)),
                                      SizedBox(
                                          height: 72.0,
                                          width: double.infinity,
                                          child: Column(
                                            children: <Widget>[
                                              Expanded(
                                                  child: StreamBuilder(
                                                    stream: addressBloc.addressStream,
                                                    builder: (context, snapshot) {
                                                      if (snapshot.data != null) {
                                                        return ListView.builder(
                                                          padding: EdgeInsets.only(left: 18.0, right: 18.0),
                                                          itemCount: (snapshot.data as List).length,
                                                          scrollDirection: Axis.horizontal,
                                                          itemBuilder: (context, index) {
                                                            return InkWell(
                                                                onTap: () {
                                                                  _sheetController.snapToPosition(SnapPosition(positionFactor: -1.0));
                                                                  placeSelected = {
                                                                    "description": snapshot.data[index]['address_name'],
                                                                  };

                                                                  currentSearchedPlace = {
                                                                    "lat": snapshot.data[index]['location']['coordinates'][1],
                                                                    "lng": snapshot.data[index]['location']['coordinates'][0]
                                                                  };

                                                                  setState(() {
                                                                    addingNewPoint = true;

                                                                    waypointIsDestination = true;
                                                                    mapScaleHeight = 1.0;
                                                                  });

                                                                  mapController.animateCamera(CameraUpdate.newLatLngZoom(new LatLng(currentSearchedPlace['lat'], currentSearchedPlace['lng']), 18.0));
                                                                },
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: <Widget>[
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.blue,
                                                                          borderRadius: BorderRadius.circular(6.0)
                                                                      ),
                                                                      margin: EdgeInsets.only(right: 12.0),
                                                                      padding: EdgeInsets.all(12.0),
                                                                      width: 52.0,
                                                                      height: 52.0,
                                                                      child: SvgPicture.network(snapshot.data[index]['address_type']['icon'].toString() ?? '', color: Colors.white),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(right: 13.0),
                                                                      child: Text(snapshot.data[index]['address_name'].toString() ?? ''),
                                                                    )
                                                                  ],
                                                                )
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        return Text('');
                                                      }
                                                    },
                                                  )
                                              ),
                                            ],
                                          )
                                      ),
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
                                                  _sheetController.snapToPosition(SnapPosition(positionFactor: -1.0, snappingDuration: Duration(milliseconds: 400)));
                                                  setState(() {
                                                    currentSearchedPlace = null;
                                                    placeSelected = currentPlaces[index];
                                                    addingNewPoint = true;
                                                    waypointIsOrigin = true;
                                                    mapScaleHeight = 1.0;
                                                  });
                                                  mapController.animateCamera(CameraUpdate.newLatLng(_center));
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
                      if (showUrbanServices && !addingNewPoint)
                        SnappingSheet(
                          snappingSheetController: _sheetController,
                          lockOverflowDrag: true,
                          initSnapPosition: SnapPosition(positionFactor: -1.0),
                          snapPositions: [
                            SnapPosition(positionFactor: 0.0)
                          ],
                          grabbingHeight:  MediaQuery.of(context).padding.bottom + 360,
                          grabbing: Stack(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
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
                                    Padding(
                                      padding: EdgeInsets.only(top: 18.0),
                                    ),
                                    SizedBox(
                                        height: 324.0,
                                        width: double.infinity,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  if (currentWaypointLocation == null)
                                                    Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              mapScaleHeight = 1.0;
                                                              addingNewPoint = true;
                                                            });
                                                            _sheetController.snapToPosition(SnapPosition(positionFactor: -1.0, snappingDuration: Duration(milliseconds: 400)));

                                                          },
                                                          child: Text('Agregar parada', style: TextStyle(decoration: TextDecoration.underline)),
                                                        )
                                                    ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: InkWell(
                                                      onTap: () {
                                                        DatePicker.showDateTimePicker(context,
                                                            showTitleActions: true,
                                                            minTime: DateTime.now(),
                                                            maxTime: DateTime.now().add(Duration(days: 7)),
                                                            onChanged: (date) {
                                                              print('change $date');
                                                            },
                                                            onCancel: () {
                                                              setState(() {
                                                                scheduledRide = null;
                                                              });
                                                            },
                                                            onConfirm: (date) {
                                                              print('confirm $date');
                                                              setState(() {
                                                                scheduledRide = date;
                                                              });
                                                            },
                                                            currentTime: scheduledRide == null ? DateTime.now() : scheduledRide,
                                                            locale: LocaleType.es
                                                        );
                                                      },
                                                      child: Text(scheduledRide == null ? 'Programar viaje' : 'Programado para ${new DateFormat('dd/MM/yyyy HH:MM').format(scheduledRide)}', textAlign: TextAlign.end, style: TextStyle(decoration: TextDecoration.underline)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                padding: EdgeInsets.only(left: 18.0, right: 18.0),
                                                itemCount: urbanServices.length,
                                                scrollDirection: Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        urbanServices.forEach((e) => e['selected'] = false);
                                                        urbanServices[index]['selected'] = true;
                                                      });
                                                    },
                                                    child: Container(
                                                        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                                        width: 102.0,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(16.0),
                                                            boxShadow: urbanServices[index]['selected'] == true ? [BoxShadow(
                                                              blurRadius: 7.0,
                                                              color: Colors.black.withOpacity(0.2),
                                                            )] : null,
                                                            color: Colors.white
                                                        ),
                                                        child: SizedBox.expand(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: <Widget>[
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(6.0)
                                                                ),
                                                                padding: EdgeInsets.all(12.0),
                                                                width: double.infinity,
                                                                height: 100.0,
                                                                alignment: Alignment.center,
                                                                child: Image.network(urbanServices[index]['photo_url']),
                                                              ),
                                                              StreamBuilder(
                                                                stream: paymentMethodSelectedBloc.paymentMethodSelectedStream,
                                                                builder: (context, snapshot) {
                                                                  if (snapshot.data != null && snapshot.data['name'] != 'corporativo') {
                                                                    return Text('Q.' + (urbanServices[index]['price']).toString() ?? '-', style: TextStyle(fontSize: 16.0));
                                                                  } else {
                                                                    return Text('');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Expanded(
                                                child: Container(
                                                  //height: 180.0,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              border: Border(top: BorderSide(color: Colors.grey[300], width: 1.0))
                                                          ),
                                                          child: InkWell(
                                                            onTap: () => Navigator.of(context).pushNamed('user/payment-methods-select'),
                                                            child: StreamBuilder(
                                                              stream: paymentMethodSelectedBloc.paymentMethodSelectedStream,
                                                              builder: (context, snapshot) {
                                                                if (snapshot.data != null) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                        'Método de pago',
                                                                        style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light')
                                                                    ),
                                                                    subtitle: Text(
                                                                      snapshot.data['card'] != null ? '•••• •••• •••• ${snapshot.data['last4']}' : snapshot.data['display_name'].toString(),
                                                                      style: TextStyle(
                                                                          color: Colors.black,
                                                                          fontFamily: 'Lato-Light',
                                                                          fontSize: 22.0
                                                                      ),
                                                                    ),
                                                                    leading: Container(
                                                                      width: 42.0,
                                                                      child: SvgPicture.network(snapshot.data['logo'].toString()),
                                                                    ),
                                                                    trailing: Icon(
                                                                        Icons.keyboard_arrow_right,
                                                                        color: Colors.grey[800],
                                                                        size: 42.0
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Text('');
                                                                }
                                                              },
                                                            )
                                                          )
                                                      ),

                                                      Container(
                                                        //height: 80.0,
                                                          padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                                                          decoration: BoxDecoration(
                                                              border: Border(top: BorderSide(color: Colors.grey[300], width: 1.0))
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Expanded(
                                                                flex: 1,
                                                                child: defaultButton(
                                                                    double.infinity,
                                                                    'Cancelar',
                                                                        () {
                                                                      setState(() {
                                                                        _polyLines = {};
                                                                        markers = {};
                                                                        mapScaleHeight = 1.0;
                                                                        currentWaypointLocation = null;
                                                                      });

                                                                      mapUserLocation();

                                                                      _sheetController.snapToPosition(SnapPosition(positionFactor: -1.1, snappingDuration: Duration(seconds: 2)));

                                                                      new Timer(Duration(seconds: 2), () {
                                                                        setState(() {
                                                                          showUrbanServices = false;
                                                                        });
                                                                        _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
                                                                      });
                                                                    },
                                                                    color: Colors.red
                                                                ),
                                                              ),
                                                              Padding(padding: EdgeInsets.only(right: 16.0)),
                                                              Expanded(
                                                                flex: 2,
                                                                child: defaultButton(
                                                                    double.infinity,
                                                                    'Confirmar viaje',
                                                                        () async {

                                                                      _sheetController.snapToPosition(SnapPosition(positionFactor: -0.8));

                                                                      confirmRide(context);
                                                                    }
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      if (lookingForPilot)
                        Container(
                          color: Color(0xFFfffff).withOpacity(1),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Buscando un piloto...', style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
                              Padding(padding: EdgeInsets.only(top: 32.0)),
                              Image.asset('assets/loading.gif', scale: 2.0),
                            ],
                          ),
                        ),
                      if (noPilots)
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('No hay conductores cercanos disponibles', textAlign: TextAlign.center, style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
                              ),
                              Padding(padding: EdgeInsets.only(top: 8.0)),
                              Image.asset('assets/no_drivers_availables.png', scale: 2.0),
                              Padding(padding: EdgeInsets.only(top: 8.0)),
                              defaultButton(
                                  MediaQuery.of(context).size.width * 0.5,
                                  'Entendido',
                                      () {
                                    setState(() {
                                      noPilots = false;
                                    });
                                    mapUserLocation();
                                  })
                            ],
                          ),
                        ),
                      if ((snapshot.data == 'Started' || snapshot.data == 'Passenger onboard') && lookingForPilot == false)
                        Positioned(
                          child: new Align(
                              alignment: FractionalOffset.bottomLeft,
                              child: Container(
                                  margin: EdgeInsets.only(left: 24.0),
                                  height: snapshot.data == 'Passenger onboard' ? MediaQuery.of(context).padding.bottom + 262 : MediaQuery.of(context).padding.bottom + 212,
                                  width: 72.0,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.only(top: 6.0)),
                                      Text('Tiempo restante', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                      Container(
                                        height: 32.0,
                                        width: double.infinity,
                                        color: Colors.black,
                                        alignment: Alignment.center,
                                        child: Text(estimatedTime == '0 mins' ? '...' : estimatedTime, style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  )
                              )
                          ),
                        ),
                      if (snapshot.data == 'Passenger onboard')
                        Positioned(
                          child: new Align(
                              alignment: FractionalOffset.bottomLeft,
                              child: InkWell(
                                onTap: () {
                                  Share.share('https://www.google.com/maps/search/?api=1&query=${_onRideLocation.latitude},${_onRideLocation.longitude}');
                                },
                                child: Container(
                                    height: MediaQuery.of(context).padding.bottom + 186,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse('0xff${(rideSnapshot.data['service']['color']).split('#')[1]}')),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(22.0),
                                        topRight: Radius.circular(22.0),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.symmetric(vertical: 8.0)),
                                        Text('Compartir mi ubicación', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                      ],
                                    )
                                ),
                              )
                          ),
                        ),
                      if ((snapshot.data == 'Accepted' || snapshot.data == 'Started' || snapshot.data == 'Paused' || snapshot.data == 'Passenger onboard') && lookingForPilot == false)
                        SnappingSheet(
                          snappingSheetController: _sheetController,
                          lockOverflowDrag: true,
                          snapPositions: [
                            SnapPosition(positionFactor: 0.0)
                          ],
                          grabbingHeight:  MediaQuery.of(context).padding.bottom + 140,
                          grabbing: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.0),
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
                                  InkWell(
                                    onTap: () => Navigator.of(context).pushNamed('ride/pilot-selected', arguments: RidePilotInfoArguments(rideSnapshot.data, snapshot.data)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 5,
                                              blurRadius: 10,
                                              offset: Offset(0, 3),
                                            ),
                                          ]
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(42.0),
                                              child: StreamBuilder(
                                                stream: rideBloc.rideStream,
                                                builder: (context, snapshot) {
                                                  if (snapshot.data != null && snapshot.data['driver']['avatar'] != null) {
                                                    return Image.network(
                                                      snapshot.data['driver']['avatar'].toString(),
                                                      fit: BoxFit.cover,
                                                    );
                                                  } else {
                                                    return Icon(Icons.person_outline, size: 46.0, color: Colors.black);
                                                  }
                                                },
                                              )
                                          ),
                                        ),
                                        title: Text(rideSnapshot.data['driver']['first_name'].toString() + ' ' + rideSnapshot.data['driver']['lastname'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                        trailing: Container(
                                          width: 64.0,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(Icons.star, color: Colors.black, size: 16.0),
                                              Text(rideSnapshot.data['driver']['rating']?.toStringAsFixed(2) ?? '', style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-light',))
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(rideSnapshot.data['vehicle']['make'].toString() + ' ' + rideSnapshot.data['vehicle']['model'].toString() + ' | ' + rideSnapshot.data['vehicle']['license_plate'].toString(), style: TextStyle(fontSize: 16.0)),
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                      if (snapshot.data == 'Finished')
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          padding: EdgeInsets.symmetric(vertical: 64.0, horizontal: 28.0),
                          color: Color(0xff292929),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0)
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text('¡Gracias por viajar con Urban!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                                    Padding(padding: EdgeInsets.only(top: 12.0)),
                                    Container(
                                      width: 72.0,
                                      height: 72.0,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(68.0),
                                          child: StreamBuilder(
                                            stream: rideBloc.rideStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.data != null && snapshot.data['driver']['avatar'] != null) {
                                                return Image.network(
                                                  snapshot.data['driver']['avatar'].toString(),
                                                  fit: BoxFit.cover,
                                                );
                                              } else {
                                                return Icon(Icons.person_outline, size: 56.0, color: Colors.black);
                                              }
                                            },
                                          )
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 12.0)),
                                    Text(rideSnapshot.data['driver']['first_name'].toString() + ' ' + rideSnapshot.data['driver']['lastname'].toString(), style: TextStyle(fontSize: 18.0)),
                                    Padding(padding: EdgeInsets.only(top: 12.0)),
                                    SmoothStarRating(
                                        allowHalfRating: false,
                                        onRated: (v) {
                                          _driverRating = v;
                                        },
                                        starCount: 5,
                                        size: 50.0,
                                        isReadOnly: false,
                                        color: Colors.black,
                                        borderColor: Colors.black,
                                        spacing: 0.0
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 22.0)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              //currentMessage = 'Ya voy.';
                                            });

                                            //sendMessage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Amable'),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _driverComment = 'Amable';
                                            });

                                            //sendMessage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Buen conductor'),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _driverComment = 'Buen conductor';
                                            });

                                            //sendMessage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Excelente'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _driverComment = 'Excelente';
                                            });

                                            //sendMessage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Buena conversación'),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _driverComment = 'Buena conversación';
                                            });

                                            //sendMessage();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.all(12.0),
                                            child: Text('Carro limpio'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10)),
                              defaultButton(double.infinity, 'Enviar', () async {

                                final Map<String, dynamic> data = {
                                  "comments": {
                                    "rating": _driverRating,
                                    "comment": '-'
                                  }
                                };

                                if (_driverComment != '') {
                                  data['comment'] = _driverComment;
                                }

                                final rateResponse = await _api.putByPath(context, 'trips/ratedriver/${rideBloc.rideInfo['_id']}', data);

                                print(rateResponse.body);

                                rideStatusBloc.modifyRideStatus('Pending');
                                rideBloc.modifyRideData(null);

                                chatSocketBloc.socket.disconnect();
                                _socketTrips.disconnect();

                                setState(() {
                                  rateDriver = false;
                                  _polyLines = {};
                                  markers = {};
                                  mapScaleHeight = 1.0;
                                  showUrbanServices = false;
                                  onRide = false;
                                  driverArrival = false;
                                  driverArrivalMessageDisplayed = false;
                                  rideAccepted = false;
                                });

                                mapUserLocation();

                              }, color: Colors.yellow[700], textColor: Colors.black)
                            ],
                          ),
                        ),
                      if (driverArrival && driverArrivalMessageDisplayed == false)
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('¡El piloto ya llegó!', textAlign: TextAlign.center, style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
                              ),
                              Padding(padding: EdgeInsets.only(top: 8.0)),
                              Image.asset('assets/driver-arrive.png', scale: 2.0),
                              Padding(padding: EdgeInsets.only(top: 8.0)),
                              defaultButton(
                                  MediaQuery.of(context).size.width * 0.5,
                                  'Entendido',
                                      () {
                                    setState(() {
                                      driverArrivalMessageDisplayed = true;
                                    });
                                  })
                            ],
                          ),
                        ),
                      if (addingNewPoint)
                        new Positioned(
                          child: new Align(
                              alignment: FractionalOffset.center,
                              child: Image.asset('assets/rides/origin-lx.png', scale: 1.5)
                          ),
                        ),
                      if (addingNewPoint)
                        new Positioned(
                          child: new Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.only(right: 24.0, bottom: MediaQuery.of(context).padding.bottom + 24.0),
                                child: defaultButton(
                                    MediaQuery.of(context).size.width * 0.5,
                                    waypointIsOrigin ? 'Confirmar origen' : waypointIsDestination ? 'Confirmar destino' : 'Seleccionar',
                                        () async {
                                      await locationMap();
                                      if (waypointIsDestination == true) {
                                        setState(() {
                                          waypointIsOrigin = true;
                                          waypointIsDestination = false;
                                        });

                                        mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 18.0));

                                        return;
                                      }

                                      if (waypointIsOrigin == false) {
                                        setLocationOnMap(context, LatLng(currentSearchedPlace['lat'], currentSearchedPlace['lng']), waypoint: currentWaypointLocation);
                                        _sheetController.snapToPosition(SnapPosition(positionFactor: 0.0));
                                      }


                                      setState(() {
                                        addingNewPoint = false;
                                        waypointIsOrigin = false;
                                        //mapScaleHeight = 0.6;
                                      });
                                    }
                                ),
                              )
                          ),
                        ),
                      if (addingNewPoint)
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
                                              searchListIsOpen = true;
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


                                                  final Response detailResponse = await Dio().get('$googleDetailUrl?json&place_id=${currentPlaces[index]['place_id']}&key=$googleMapsKey');

                                                  final thisPlace = detailResponse.data['result']['geometry']['location'];
                                                  //final currentPosition = await getCurrentPosition();

                                                  mapController.animateCamera(CameraUpdate.newLatLng(LatLng(thisPlace['lat'], thisPlace['lng'])));

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
                      if (requestGender)
                        Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.white,
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Ingresa tu género', style: TextStyle(color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.bold),),
                                Padding(padding: EdgeInsets.only(top: 24.0),),
                                Text('Urban ofrece servicios personalizados según tu genero, indicanos tu género para mejorar tu experiencia.', textAlign: TextAlign.center,),
                                Padding(padding: EdgeInsets.only(top: 46.0),),
                                Form(
                                  key: _formGender,
                                  child: Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          validator: (v) => v == null ? 'Este campo es obligatorio' : null,
                                          onChanged: (v) => _requestedGender = v,
                                          isExpanded: true,
                                          icon: null,
                                          iconSize: 0,
                                          items: <String>['Masculino', 'Femenino'].map((String value) {
                                            return new DropdownMenuItem<String>(
                                              value: value == 'Femenino' ? 'f' : 'm',
                                              child: new Text(value),
                                            );
                                          }).toList(),
                                          hint: Text('Selecciona tu género'),
                                          decoration: InputDecoration.collapsed(hintText: null),
                                        ),
                                        Padding(padding: EdgeInsets.only(top: 46.0),),
                                        defaultButton(double.infinity, 'Continuar', () async {
                                          if (_formGender.currentState.validate()) {
                                            _formGender.currentState.save();

                                            _utils.loadingDialog(context);

                                            final response = await _api.putByPath(context, 'users/${bloc.userInfo['_id']}', {
                                              "gender": _requestedGender
                                            });

                                            final data = jsonDecode(response.body);
                                            if (data['success'] == false) {
                                              _utils.closeDialog(context);
                                              return _utils.messageDialog(context, 'Error', data['error']['errors'][0]);
                                            }

                                            print(data['data']);

                                            bloc.modifyUserData(data['data']);

                                            _utils.closeDialog(context);

                                            setState(() {
                                              requestGender = false;
                                            });
                                          }
                                        })
                                      ],
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
            );
          },
        )
      ),
    );
  }

  void check(CameraUpdate u, GoogleMapController c) async {

    mapController.animateCamera(u);
    LatLngBounds l1=await c.getVisibleRegion();
    LatLngBounds l2=await c.getVisibleRegion();
    if(l1.southwest.latitude==-90 ||l2.southwest.latitude==-90) {
      check(u, c);
    } else {
      c.animateCamera(u);
    }

  }

  Future<bool> chosenService() async {
      bool cService = false;

      urbanServices.forEach((element) {
        if (element['selected'] == true) {
          cService = true;
        }
      });

      return cService;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    assert(list.isNotEmpty);
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

}
