import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/rides/rideChat.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';

class RidePilotInfoPage extends StatefulWidget {
  @override
  _RidePilotInfoPageState createState() => _RidePilotInfoPageState();
}

class _RidePilotInfoPageState extends State<RidePilotInfoPage>  with AfterInitMixin<RidePilotInfoPage> {
  RidePilotInfoArguments args;

  final _api = Api();
  final _utils = Utils();

  dynamic countRides = '-';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void didInitState() {
    args = ModalRoute.of(context).settings.arguments;
    getData(context);
  }

  getDriverTime(DateTime date) {
    return '';
    final int days = (DateTime.now()).difference(date).inDays;

    if (days < 60) {
      return '$days días';
    } else {
      return '${days / 60} meses';
    }
  }


  getData(BuildContext context) async {
    final countResponse = await _api.getByPath(context, 'trips/counttrips/${args.data['driver']['id']}');

    final countData = jsonDecode(countResponse.body);

    if (countData['success'] == true)
    setState(() {
      countRides = countData['data']['count'];
    });
  }


  @override
  Widget build(BuildContext context) {
    final rideBloc = Provider.of(context).rideBloc;
    final rideStatusBloc = Provider.of(context).rideStatusBloc;

    print(rideBloc.rideInfo);
    return Scaffold(
      appBar: urbanAppBar(context, args.data['driver']['first_name'].toString() + ' ' + args.data['driver']['lastname'].toString(), true),
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      image: NetworkImage(rideBloc.rideInfo['vehicle']['side_photo'].toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 182.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(args.data['vehicle']['make'].toString() + ' ' + args.data['vehicle']['line'].toString(), style: TextStyle(color: Colors.white)),
                      Text(args.data['vehicle']['license_plate'].toString(), style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text('Viajes', textAlign: TextAlign.center,),
                          ),
                          Spacer(),
                          Expanded(
                            child: Text('Tiempo', textAlign: TextAlign.center,),
                          )
                        ],

                      ),
                      Padding(padding: EdgeInsets.only(top: 6.0)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(countRides.toString(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                          ),
                          Spacer(),
                          Expanded(
                            child: Text(rideBloc.rideInfo['driver']['created_at'] != null ? getDriverTime(DateTime.parse(rideBloc.rideInfo['driver']['created_at'])): '', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                          )
                        ],

                      ),
                      Padding(padding: EdgeInsets.only(top: 24.0)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: defaultButton(double.infinity, 'Llamar', () => launch("tel://${args.data['driver']['phone_number']}")),
                          ),
                          Spacer(),
                          Expanded(
                            flex: 8,
                            child: defaultButton(double.infinity, 'Enviar mensaje', () => Navigator.of(context).pushNamed('ride/chat', arguments: RideChatPageArguments(args.data)), color: Colors.black),
                          )
                        ],

                      ),
                      Padding(padding: EdgeInsets.only(top: 18.0)),
                      Container(
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.grey[300], width: 1.0))
                          ),
                          child: InkWell(
                            onTap: () => null,
                            child: ListTile(
                              title: Text(
                                  'Método de pago',
                                  style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light')
                              ),
                              subtitle: Text(
                                rideBloc.rideInfo['payment_method']['display_name'].toString() ?? '',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Lato-Light',
                                    fontSize: 22.0
                                ),
                              ),
                              leading: Container(
                                width: 42.0,
                                child: SvgPicture.network(rideBloc.rideInfo['payment_method']['logo'].toString() ?? ''),
                              ),
                              trailing: Text('Q'+args.data['fare'].toString(), style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold))
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 42.0)),
                if (args.rideStatus != 'Passenger onboard')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.25),
                    child: InkWell(
                      onTap: () async {
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
                              rideStatusBloc.modifyRideStatus('Pending');
                              await _utils.messageDialog(context, 'Cancelado', 'Se cancelo el viaje');

                              return Navigator.of(context).pop();
                            }


                          }
                        }


                      },
                      child: Text('Cancelar viaje', style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontSize: 18.0)),
                    ),
                  )
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.34,
              ),
              margin: EdgeInsets.only(top: 112.0),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(120.0),
                child: AspectRatio(
                  aspectRatio: 420 / 420,
                  child: Image.network(
                    args.data['driver']['avatar'].toString() ?? '',
                    fit: BoxFit.cover,
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class RidePilotInfoArguments {
  final Map<dynamic, dynamic> data;
  final String rideStatus;

  RidePilotInfoArguments(this.data, this.rideStatus);
}

