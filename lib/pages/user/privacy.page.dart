import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/pages/user/privacyOptions.page.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  List privacyItems = [
    {
      "name": "Privacidad 1",
      "items": [
        {
          "name": "Opción 1",
          "status": false
        },
        {
          "name": "Opción 2",
          "status": false
        },
        {
          "name": "Opción 3",
          "status": false
        }
      ]
    },
    {
      "name": "Privacidad 2",
      "items": [
        {
          "name": "Opción 1",
          "status": false
        },
        {
          "name": "Opción 2",
          "status": false
        },
        {
          "name": "Opción 3",
          "status": false
        }
      ]
    }
  ];

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
      appBar: urbanAppBar(context, 'Privacidad', false),
      body: Container(
        child: ListView.builder(
          itemCount: privacyItems.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.of(context).pushNamed('user/privacy-options', arguments: PrivacyOptionsPageArguments(privacyItems[index])),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
                ),
                child: ListTile(
                  title: Text(privacyItems[index]['name']),
                  trailing: Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.grey[800],
                      size: 42.0
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
