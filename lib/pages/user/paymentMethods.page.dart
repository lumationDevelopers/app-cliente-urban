import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:client/bloc/cards.bloc.dart';
import 'package:client/bloc/paymentMethods.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/pages/user/paymentMethodsDetail.page.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethodsPage extends StatefulWidget {
  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> with AfterInitMixin<PaymentMethodsPage> {

  List<Widget> userPayments = [];

  CardsBloc cardsBloc;
  PaymentMethodsBloc paymentMethodsBloc;

  final _api = Api();
  final _utils = Utils();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  List<Widget> getCards(List cards) {

    List<Widget> newPayments = [];

    cards.forEach((e) {
      newPayments.add(
          InkWell(
              onTap: () => Navigator.of(context).pushNamed('user/payment-methods-detail', arguments: PaymentMethodsDetailPageArguments(e)),
              child: Container(
                height: 64.0,
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
                padding: EdgeInsets.all(4.0),
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
                    Expanded(
                        child: ListTile(
                          title: Text('•••• •••• •••• ${e['last4']}',
                              style: TextStyle(fontSize: 20.0, fontFamily: 'Lato-Light')
                          ),
                          leading: Container(
                            width: 42.0,
                            child: SvgPicture.asset('assets/payments/electronic-icon.svg'),
                          ),
                          /*trailing: Text('Principal',
                              style: TextStyle(
                                  fontFamily: 'Lato-Light'
                              )
                          )*/
                        )
                    ),
                  ],
                ),
              )
            )
        );
    });

    return newPayments;


  }

  List<Widget> getPaymentMethods(List payments) {

    List<Widget> newPayments = [];

    payments.removeWhere((element) => element['name'] == 'tarjeta');

    payments.forEach((e) {
      newPayments.add(
          Container(
            height: 64.0,
            width: double.infinity,
            margin: EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 18.0),
            padding: EdgeInsets.all(4.0),
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
                Expanded(
                    child: ListTile(
                        title: Text(e['display_name'].toString(),
                            style: TextStyle(fontSize: 20.0)),
                        leading: Container(
                          width: 42.0,
                          child: SvgPicture.network(e['logo'].toString()),
                        ),
                    )
                ),
              ],
            ),
          )
      );
    });

    return newPayments;


  }

  @override
  void didInitState() {
    // TODO: implement didInitState
  }


  @override
  Widget build(BuildContext context) {
    cardsBloc = Provider.of(context).cardsBloc;
    paymentMethodsBloc = Provider.of(context).paymentMethodsBloc;

    return Scaffold(
      appBar: urbanAppBar(context, 'Métodos de pago', true),
      body: StreamBuilder(
        stream: cardsBloc.cardsStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return ListView(
              children: <Widget>[
                ...getCards(cardsBloc.cards),
                ...getPaymentMethods(paymentMethodsBloc.paymentMethods),
                InkWell(
                  onTap: () =>
                      Navigator.of(context).pushNamed(
                          'user/add-payment-methods'),
                  child: Container(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        Icon(Icons.add_circle_outline, size: 50.0),
                        Text("Agregar método de pago", style: TextStyle(
                            fontSize: 20.0, fontFamily: 'Lato-Light'),)
                      ],
                    ),
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
