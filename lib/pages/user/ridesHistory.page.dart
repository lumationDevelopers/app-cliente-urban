import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/rides/ridePilotInfo.page.dart';
import 'package:client/pages/user/ridesHistoryDetail.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/maps.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:after_init/after_init.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class RidesHistoryPage extends StatefulWidget {
  @override
  _RidesHistoryPageState createState() => _RidesHistoryPageState();
}

class _RidesHistoryPageState extends State<RidesHistoryPage> with AfterInitMixin<RidesHistoryPage> {
  List<dynamic> rides = [];
  RidesHistoryArguments args;

  final _api = new Api();
  final _utils = new Utils();
  final _maps = new Maps();

  getData(String userId) async  {
    final response = await _api.getByPath(context, 'trips?user.id=$userId&trip_status=Finished&limit=75');

    final data = jsonDecode(response.body);

    print(data['data'][0]['pickup']['coordinates'][0]);


    if (data['success'] == false) {
      Navigator.of(context).pop();
      return _utils.messageDialog(context, 'Error', 'No se pudieron cargar los datos.');
    }


    (data['data']).forEach((e) {
      if (e['finished_at'] != null) {
        var date = (e['finished_at'].split('T')[0]).split('-');
        var time = e['finished_at'].split('T')[1];

        e['finished_at'] = '${date[2]}/${date[1]}/${date[0]} $time';
      }

      switch(e['trip_status']) {
        case 'Created':
          e['trip_status'] = 'Creado'; break;
        case 'Cancelled':
          e['trip_status'] = 'Cancelado'; break;
        case 'Finished':
          e['trip_status'] = 'Finalizado'; break;
      }

    });

    setState(() {
      rides = data['data'];
    });

  }

  countStars(int count) {
    List<Widget> starts = [];
    for (var i = 0; i < count; i++) {
      starts.add(Icon(Icons.star, color: Colors.black, size: 18.0));
    }

    return starts;
  }

  @override
  void didInitState() {
    args = ModalRoute.of(context).settings.arguments;
    getData(args.userId);
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

    return Scaffold(
        appBar: urbanAppBar(context, 'Historial de viajes', true),
        body: Stack(
          children: <Widget>[
            if (rides.length > 0)
              Container(
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).pushNamed('user/rides-history-detail', arguments: RidesHistoryDetailPageArguments(rides[index])),
                      child: Container(

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
                            /*new FutureBuilder(
                              future: _maps.generateRouteImage(rides[index]['pickup']['coordinates'][0], rides[index]['pickup']['coordinates'][1], rides[index]['destination']['coordinates'][0], rides[index]['destination']['coordinates'][1], 512, 260), // a Future<String> or null
                              builder: (BuildContext context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none: return new Text('Press button to start');
                                  case ConnectionState.waiting: return new CircularProgressIndicator(backgroundColor: Colors.black,);
                                  default:
                                    if (snapshot.hasError)
                                      return new Text('Error: ${snapshot.data}');
                                    else
                                      return new Text('Result: ${snapshot.data}');
                                }
                              },
                            ),*/
                            ListTile(
                                    title: Container(
                                      child: Text('${rides[index]['destination']['address']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0)),
                                    ),
                                    subtitle: Text(rides[index]['finished_at'] != null ? rides[index]['finished_at'].split('.')[0] : ''),
                                    trailing: Container(
                                      height: 42.0,
                                      width: 120.0,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text('Q${rides[index]['fare']}', style: TextStyle(fontSize: 0.0)),
                                          Expanded(
                                            child: Container(
                                              width: 120.0,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  if ((rides[index]['comments']).length > 0)
                                                    ...countStars(rides[index]['comments'][(rides[index]['comments']).length-1]['rating']),
                                                  if ((rides[index]['comments']).length < 1)
                                                    Text(rides[index]['trip_status'])
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
                    );
                  },
                ),
              ),
            if (rides.length < 1)
              Container(
                padding: EdgeInsets.all(32.0),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.directions_car, size: MediaQuery.of(context).size.width * 0.4),
                    Padding(padding: EdgeInsets.only(top: 42.0)),
                    Text('No tienes ningún viaje', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.only(top: 12.0)),
                    Text('Empieza a utilizar los servicios que te ofrece Urban.', textAlign: TextAlign.justify, style: TextStyle(fontSize: 22.0))

                  ],
                ),
              )
          ],
        )
    );
  }
}

class RidesHistoryArguments {
  final String userId;

  RidesHistoryArguments(this.userId);
}