import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/maps.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../credentials.dart';

class ScheduledRideDetailPage extends StatefulWidget {
  @override
  _ScheduledRideDetailPageState createState() => _ScheduledRideDetailPageState();
}

class _ScheduledRideDetailPageState extends State<ScheduledRideDetailPage> with AfterInitMixin<ScheduledRideDetailPage>{

  final _api = new Api();
  final _utils = new Utils();
  final _maps = new Maps();

  String mapUrl = '';

  parseDate(String date) async {
    print(date);
    var dates = (date.split('T')[0]).split('-');
    var time = date.split('T')[1];

    return '${dates[2]}/${dates[1]}/${dates[0]} $time';
  }

  @override
  void didInitState() {
    // TODO: implement didInitState

    final data = (ModalRoute.of(context).settings.arguments as ScheduledRideDetailPageArguments).data;

    generateRouteImage(data['pickup']['coordinates'][1], data['pickup']['coordinates'][0], data['destination']['coordinates'][1], data['destination']['coordinates'][0], 512, 260);
  }


  generateRouteImage(startLat, startLng, endLat, endLng, int width, int height) async {

    final Response directionResponse = await Dio().get('https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$googleMapsKey');

    setState(() {
      mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?&size=${width}x$height&markers=color:black%7C$startLat,$startLng&markers=color:red%7C$endLat,$endLng&path=weight:5%7Ccolor:0xD93D85%7Cenc:${directionResponse.data["routes"][0]["overview_polyline"]["points"]}&key=$googleMapsKey';
    });

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
    final ScheduledRideDetailPageArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: urbanAppBar(context, 'Detalles del viaje', false),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  /*Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                            child: Image.asset('assets/map-example.png'),
                          )
                        ),*/
                  ClipRRect(
                    child: Image.network(mapUrl),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  ListTile(
                          title: Container(
                            child: Text(new DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(args.data['request_time'])), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0)),
                          ),
                          subtitle: Text(args.data['payment_method']['display_name'], style: TextStyle(fontSize: 16.0)),
                          trailing: Container(
                            height: 42.0,
                            width: 80.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                //Text('Q'+args.data['fare'].toString(), style: TextStyle(fontSize: 18.0)),
                                Expanded(
                                  child: Container(
                                    width: 120.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(args.data['distance_estimate'].toString() + ' KM')
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                      )
                ],
              ),
            ),
            Container(
              height: 200.0,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
              padding: EdgeInsets.all(14.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Hoja de ruta', style: TextStyle(fontSize: 22.0)),
                  Expanded(
                      child: ListTile(
                          title: Container(
                            child: Text(args.data['pickup']['address'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0)),
                          ),
                          //subtitle: Text(args.data['payment_method']['display_name'], style: TextStyle(fontSize: 16.0)),
                          leading: Container(
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.all(0),
                            width: 32.0,
                            height: 32.0,
                            child: Image.network(args.data['service']['pickup_url'] ?? '', scale: 0.1),
                          )
                      )
                  ),
                  Expanded(
                      child: ListTile(
                          title: Container(
                            child: Text(args.data['destination']['address'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0)),
                          ),
                          //subtitle: Text(args.data['payment_method']['display_name'], style: TextStyle(fontSize: 16.0)),
                          leading: Container(
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.all(0),
                            width: 32.0,
                            height: 32.0,
                            child: Image.network(args.data['service']['dropoff_url'] ?? '', scale: 0.1),
                          )
                      )
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 24.0)),
            Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25),
                child: defaultButton(
                    double.infinity,
                    'Cancelar viaje',
                    () async {
                      final confirmation = await _utils.confirmDialog(
                          context,
                          'Cancelar viaje',
                          '¿Estás seguro de cancelar el viaje?',
                          acceptText: 'Cancelar viaje',
                          cancelText: 'Cerrar'
                      );

                      if (confirmation) {
                        final message = await _utils.inputDialog(
                            context,
                            'Deja un comentario',
                            acceptText: 'Cancelar viaje',
                            cancelText: 'Cerrar'
                        );

                        if (message['response'] == true) {
                          final cancelResponse = await _api.putByPath(context, 'trips/canceltrip/${args.data['_id']}', {
                            "comment": message['message']
                          });

                          print(cancelResponse.body);

                          if (cancelResponse.statusCode == 200) {
                            print(cancelResponse.body);
                            await _utils.messageDialog(context, 'Cancelado', 'Se cancelo el viaje');

                            return Navigator.of(context).pop();
                          }


                        }
                      }
                    },
                    color: Colors.red[600]
                )
            ),
            Padding(padding: EdgeInsets.only(top: 24.0 + MediaQuery.of(context).padding.bottom)),
          ],
        ),
      ),
    );
  }
}

class ScheduledRideDetailPageArguments {
  final Map<dynamic, dynamic> data;

  ScheduledRideDetailPageArguments(this.data);
}