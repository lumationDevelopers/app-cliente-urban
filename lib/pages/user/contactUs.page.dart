import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/services/api.service.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> with AfterInitMixin<ContactUsPage> {

  List<Widget> contacts = [];

  final _api = new Api();
  final _utils = new Utils();

  getData() async  {
    final response = await _api.getByPath(context, 'contactus');

    final data = jsonDecode(response.body);

    print(data['data']);

    if (data['success'] == false) {
      Navigator.of(context).pop();
      return _utils.messageDialog(context, 'Error', 'No se pudieron cargar los datos.');
    }

    (data['data'] as List).forEach((e) {
      setState(() {
        contacts.add(
          Container(
              height: 78.0,
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
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
              child: InkWell(
                onTap: () {
                  switch (e['contactus_name']) {
                    case 'llamada': launch("tel://${e['contact_value']}"); break;
                    case 'whatsapp': launch('whatsapp://send?phone=${e['contact_value']}'); break;
                    case 'email': launch('mailto:${e['contact_value']}'); break;
                  }
                },
                child: ListTile(
                  title: Text(e['display_name'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 20.0)),
                  subtitle: Text(e['contact_value']),
                  leading: SvgPicture.network(e['photo_url'].toString()),
                ),
              )
          ),
        );
      });
    });

  }

  @override
  void didInitState() {
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);

    return Scaffold(
      appBar: urbanAppBar(context, 'Contáctanos', true),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
              child: Text(
                "Estamos disponibles para ti las 24 horas del día.",
                style: TextStyle(fontFamily: 'Lato-Light', fontSize: 22.0),
              ),
            ),
          ),
          ...contacts
        ],
      ),
    );
  }
}
