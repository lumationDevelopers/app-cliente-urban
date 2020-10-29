import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/widgets/appBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context).userBloc;

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, size: 46.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.of(context).pushNamed('user/personal-info'),
            child: Container(
                color: Colors.black,
                height: 204.0,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            width: 120.0,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(68.0),
                                child: StreamBuilder(
                                  stream: bloc.userStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null || snapshot.data['avatar'] == null) {
                                      return Icon(Icons.person_outline, size: 120.0, color: Colors.white);
                                    } else {
                                      return Image.network(
                                        snapshot.data['avatar'].toString() ?? '',
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                )
                            ),
                          ),
                          Container(
                              width: 120.0,
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                width: 32.0,
                                height: 32.0,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () => Navigator.of(context).pushNamed('user/personal-info'),
                                  color: Colors.orangeAccent,
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                  shape: CircleBorder(),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                    Expanded(
                        child: StreamBuilder(
                          stream: bloc.userStream,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return Text(
                                '${snapshot.data['name'].toString()} ${snapshot.data['lastname'].toString()}',
                                style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                              );
                            } else {
                              return Text('');
                            }

                          },
                        )
                    ),
                    Container(
                      width: 62.0,
                      height: 32.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: Icon(Icons.star, color: Colors.white, size: 16.0)),
                          Expanded(
                              child: StreamBuilder(
                                stream: bloc.userStream,
                                builder: (context, snapshot) {
                                  if (snapshot.data != null && snapshot.data['rating'] != null) {
                                    return Text((snapshot.data['rating']).toStringAsFixed(2), style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: 'Lato-light'));
                                  } else {
                                    return Text('0.00', style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: 'Lato-light'),);
                                  }
                                },
                              )
                          )
                        ],
                      ),
                    )
                  ],
                )
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed('user/phone-number'),
                      child: ListTile(
                        title: Text(
                          'Número de teléfono',
                          style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light'),
                        ),
                        subtitle: StreamBuilder(
                          stream: bloc.userStream,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return Text(
                                snapshot.data['phone_number'] ?? 'Ingresa un télefono',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Lato-Light',
                                    fontSize: 22.0
                                ),
                              );
                            } else {
                              return Text('');
                            }
                          },
                        ),
                        trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey[800],
                            size: 42.0
                        ),
                      ),
                    )
                ),
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
                    ),
                    child: InkWell(
                      onTap: () => null /*Navigator.of(context).pushNamed('user/gender') */,
                      child: ListTile(
                        title: Text(
                          'Género',
                          style: TextStyle(fontSize: 16.0, fontFamily: 'Lato-Light'),
                        ),
                        subtitle: StreamBuilder(
                          stream: bloc.userStream,
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              return Text(
                                snapshot.data['display_gender']['name'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Lato-Light',
                                    fontSize: 22.0
                                ),
                              );
                            } else {
                              return Text('');
                            }
                          },
                        ),
                        trailing: null /*Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.grey[800],
                            size: 42.0
                        ) */,
                      ),
                    )
                ),
              ],
            ),
          ),
          Expanded(child: Image.asset('assets/logo-urban.png', scale: 5.0))
        ],
      )
    );
  }
}
