import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/services/maps.service.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../credentials.dart';

class RidesHistoryDetailPage extends StatefulWidget {
  @override
  _RidesHistoryDetailPageState createState() => _RidesHistoryDetailPageState();
}

class _RidesHistoryDetailPageState extends State<RidesHistoryDetailPage> with AfterInitMixin<RidesHistoryDetailPage>{

  final _maps = new Maps();

  String mapUrl = '';

  RidesHistoryDetailPageArguments args;

  parseDate(String date) async {
    print(date);
    var dates = (date.split('T')[0]).split('-');
    var time = date.split('T')[1];

    return '${dates[2]}/${dates[1]}/${dates[0]} $time';
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
  void didInitState() {
    // TODO: implement didInitState

    final data = (ModalRoute.of(context).settings.arguments as RidesHistoryDetailPageArguments).data;

    generateRouteImage(data['pickup']['coordinates'][1], data['pickup']['coordinates'][0], data['destination']['coordinates'][1], data['destination']['coordinates'][0], 512, 260);
  }

  generateRouteImage(startLat, startLng, endLat, endLng, int width, int height) async {
    final Response directionResponse = await Dio().get('https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&key=$googleMapsKey');

    setState(() {
      mapUrl = 'https://maps.googleapis.com/maps/api/staticmap?&size=${width}x$height&markers=color:black%7C$startLat,$startLng&markers=color:red%7C$endLat,$endLng&path=weight:5%7Ccolor:0xD93D85%7Cenc:${directionResponse.data["routes"][0]["overview_polyline"]["points"]}&key=$googleMapsKey';
    });

  }


  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: urbanAppBar(context, 'Detalles del viaje', false),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
            //height: 272.0,
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
                ClipRRect(
                  child: Image.network(mapUrl),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                ListTile(
                        title: Container(
                          child: Text(args.data['finished_at'] != null ? args.data['finished_at'].split('.')[0] : '', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0)),
                        ),
                        subtitle: Text(args.data['payment_method']['display_name'], style: TextStyle(fontSize: 16.0)),
                        trailing: Container(
                          height: 42.0,
                          width: 80.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text('Q'+args.data['fare'].toString(), style: TextStyle(fontSize: 18.0)),
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
                            child: Text(args.data['pickup']['address'].toString(), overflow: TextOverflow.clip, style: TextStyle(fontSize: 16.0)),
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
                          child: Text(args.data['destination']['address'].toString(), overflow: TextOverflow.clip, style: TextStyle(fontSize: 16.0)),
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
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(6.0),
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
                      child: Image.network(
                        args.data['driver']['avatar'].toString() ?? '',
                        fit: BoxFit.cover,
                      )
                  ),
                ),
                title: Text(args.data['driver']['first_name'].toString() + ' ' + args.data['driver']['lastname'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                trailing: Container(
                  width: 64.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(Icons.star, color: Colors.black, size: 16.0),
                      Text(args.data['driver']['rating'].toStringAsFixed(2), style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-light',))
                    ],
                  ),
                ),
                subtitle: Text(args.data['vehicle']['make'].toString() + ' ' + args.data['vehicle']['model'].toString() + ' | ' + args.data['vehicle']['license_plate'].toString(), style: TextStyle(fontSize: 16.0)),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 24.0)),
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25),
              child: defaultButton(
                double.infinity,
                'Reporta problema',
                () => null
              )
            ),
            Padding(padding: EdgeInsets.only(top: 24.0 + MediaQuery.of(context).padding.bottom)),
          ],
        ),
      ),
    );
  }
}

class RidesHistoryDetailPageArguments {
  final Map<dynamic, dynamic> data;

  RidesHistoryDetailPageArguments(this.data);
}