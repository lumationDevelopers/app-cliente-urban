import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PaymentMethodsDetailPage extends StatefulWidget {
  @override
  _PaymentMethodsDetailPageState createState() => _PaymentMethodsDetailPageState();
}

class _PaymentMethodsDetailPageState extends State<PaymentMethodsDetailPage> {

  List<Widget> userPayments = [];

  final _api = Api();
  final _utils = Utils();

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
    final cardsBloc = Provider.of(context).cardsBloc;
    final PaymentMethodsDetailPageArguments args = ModalRoute.of(context).settings.arguments;

    print(args.data);
    return Scaffold(
      appBar: urbanAppBar(context, 'Métodos de pago', false),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 64.0,
                        child: SvgPicture.asset('assets/payments/electronic-icon.svg'),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('•••• •••• •••• ${args.data['last4']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28.0, fontFamily: 'Lato-Light')
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(top: 16.0)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('Válida hasta ${args.data['expire_month']}/${args.data['expire_year']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22.0, fontFamily: 'Lato-Light')
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(top: 18.0)),
                ],
              )
            ),
            Padding(padding: EdgeInsets.only(top: 32.0)),
            InkWell(
              onTap: () async {
                final message = await _utils.confirmDialog(context, 'Elimiar tarjeta', 'Se eliminará la tarjeta permanentemente');

                if (message) {

                  _utils.loadingDialog(context);

                  final deleteResponse = await this._api.deleteByPath(context, 'cards/${args.data['_id']}');

                  _utils.closeDialog(context);
                  if (deleteResponse.statusCode != 200) {
                    return _utils.messageDialog(context, 'Error', 'No se ha eliminado. Inténtalo de nuevo');
                  }

                  final cards = cardsBloc.cards;
                  cards.removeWhere((element) => element['_id'] == args.data['_id']);

                  cardsBloc.modifyCards(cards);

                  return Navigator.of(context).pop();

                }
              },
              child: Text('Eliminar', style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontSize: 18.0)),
            )
          ],
        ),
      )
    );
  }
}

class PaymentMethodsDetailPageArguments {
  final Map data;

  PaymentMethodsDetailPageArguments(this.data);
}
