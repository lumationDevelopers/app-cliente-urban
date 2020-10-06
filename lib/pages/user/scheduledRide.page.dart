import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/pages/user/scheduledRideDetail.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/services/maps.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduledRidesPage extends StatefulWidget {
  @override
  _ScheduledRidesPageState createState() => _ScheduledRidesPageState();
}

class _ScheduledRidesPageState extends State<ScheduledRidesPage> with AfterInitMixin<ScheduledRidesPage>{
  List<dynamic> rides = [];
  ScheduledRideArguments args;

  final _api = new Api();
  final _utils = new Utils();
  final _maps = new Maps();

  getData(String userId) async  {
    final response = await _api.getByPath(context, 'trips?user.id=$userId&scheduled=true&limit=75');

    final data = jsonDecode(response.body);

    print(data['data']);
    if (data['success'] == false) {
      Navigator.of(context).pop();
      return _utils.messageDialog(context, 'Error', 'No se pudieron cargar los datos.');
    }

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
    args = ModalRoute.of(context).settings.arguments;
    getData(args.userId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: urbanAppBar(context, 'Viajes programados', true),
      body: Stack(
        children: <Widget>[
          if (rides.length > 0)
            ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.of(context).pushNamed('user/scheduled-rides-detail', arguments: ScheduledRideDetailPageArguments(rides[index])),
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

                        ListTile(
                                title: Text('${rides[index]['destination']['address']}', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0)),
                                subtitle: Text( new DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(rides[index]['request_time']))),
                                trailing: Container(
                                  height: 42.0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Q${rides[index]['fare']}', style: TextStyle(fontSize: 0.0)),
                                      Text(rides[index]['distance_estimate'].toString() + ' KM')
                                      /*Expanded(
                                      child: Container(
                                        width: 120.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            ...countStars(rides[index]['comments'][(rides[index]['comments']).length-1]['rating']),
                                          ],
                                        ),
                                      ),
                                    )*/
                                    ],
                                  ),
                                )
                            )

                      ],
                    ),
                  )
                );
              },
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
                  Icon(Icons.calendar_today, size: MediaQuery.of(context).size.width * 0.4),
                  Padding(padding: EdgeInsets.only(top: 42.0)),
                  Text('No tienes ningún viaje programado', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  Padding(padding: EdgeInsets.only(top: 12.0)),
                  Text('Programa un viaje con anticipación en el mapa y un piloto llegará por tí el día que desees.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.0))

                ],
              ),
            )
        ],
      ),
    );
  }
}

class ScheduledRideArguments {
  final String userId;

  ScheduledRideArguments(this.userId);
}
