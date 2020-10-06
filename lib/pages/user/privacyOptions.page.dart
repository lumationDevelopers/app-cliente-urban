import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/material.dart';

class PrivacyOptionsPage extends StatefulWidget {
  @override
  _PrivacyOptionsPageState createState() => _PrivacyOptionsPageState();
}

class _PrivacyOptionsPageState extends State<PrivacyOptionsPage> {

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
    PrivacyOptionsPageArguments args = ModalRoute.of(context).settings.arguments;

    print(args.data);
    return Scaffold(
      appBar: urbanAppBar(context, args.data['name'], false),
      body: Container(
        child: ListView.builder(
          itemCount: args.data['items'].length,
          itemBuilder: (context, index) {
            return InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
                ),
                child: ListTile(
                  title: Text(args.data['items'][index]['name']),
                  trailing: Switch(
                    value: args.data['items'][index]['status'],
                    onChanged: (value) {
                      setState(() {
                        args.data['items'][index]['status'] = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
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

class PrivacyOptionsPageArguments {
  final Map<dynamic, dynamic> data;

  PrivacyOptionsPageArguments(this.data);
}