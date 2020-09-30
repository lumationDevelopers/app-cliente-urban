import 'dart:convert';

import 'package:after_init/after_init.dart';
import 'package:client/bloc/chatSocket.bloc.dart';
import 'package:client/bloc/provider.bloc.dart';
import 'package:client/credentials.dart';
import 'package:client/widgets/appBar.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RideChatPage extends StatefulWidget {
  @override
  _RideChatPageState createState() => _RideChatPageState();
}

class _RideChatPageState extends State<RideChatPage> with AfterInitMixin<RideChatPage> {

  var _textFieldController = TextEditingController();
  RideChatPageArguments args;
  var _socket;

  var bloc;

  List messages = [];

  String currentMessage = '';

  void prepareChat() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    _socket = IO.io('$socketUri/chats?token=${storage.getString('user_token')}', <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('message', (value) {
      setState(() {
        messages.add({
          "username": value['username'],
          "text": value['text'],
          "time": value['time']
        });
      });
    });

    _socket.on('event', (data) => print('sdsds' + jsonDecode(data)));
    _socket.on('disconnect', (_) => startChat());
    _socket.on('fromServer', (_) => print('asdsdsd' + jsonDecode(_)));

    startChat();
  }

  void startChat() async {

    _socket.connect();
    _socket.on('connect', (_) {
      if (!_socket.connected) {
        return startChat();
      }
      _socket.emit('joinchat', {
        "displayname": bloc.userInfo['username'],
        "user": args.data['user']['_id'],
        "trip": args.data['_id']
      });
    });
  }

  ChatSocketBloc chatSocketBloc;
  sendMessage() {
    if (currentMessage != '') {
      chatSocketBloc.socket.emit('chatmessage', {
        "displayname": bloc.userInfo['username'],
        "user": args.data['user']['_id'],
        "trip": args.data['_id'],
        "message": currentMessage
      });

      /*setState(() {
        messages.add({
          "username": args.data['user']['username'],
          "message": currentMessage
        });
      });*/

      setState(() {
        currentMessage = '';
        _textFieldController.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didInitState() {
    // TODO: implement didInitState
    //prepareChat();
  }


  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    final chatBloc = Provider.of(context).chatBloc;
    chatSocketBloc = Provider.of(context).chatSocketBloc;

    bloc = Provider.of(context).userBloc;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: urbanAppBar(context, args.data['driver']['first_name'].toString() + ' ' + args.data['driver']['lastname'].toString(), true),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: CircularNotchedRectangle(),
        child: Container(
            color: Colors.transparent,
            height: 148.0,
            width: double.infinity,
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            currentMessage = 'Ya voy.';
                          });

                          sendMessage();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Text('Ya voy.'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            currentMessage = 'Muchas gracias.';
                          });

                          sendMessage();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Text('Muchas gracias.'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            currentMessage = '¿Podría esperar un momento?.';
                          });

                          sendMessage();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Text('¿Podría esperar un momento?.'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.0),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(accentColor: Colors.black, primaryColor: Colors.black),
                    child: TextField(
                      controller: _textFieldController,
                      onChanged: (v) {
                        setState(() {
                          currentMessage = v;
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Colors.black,
                          hintText: 'Escribir mensaje...',
                          suffix: InkWell(
                            onTap: () => sendMessage(),
                            child: Icon(Icons.send, color: Colors.black),
                          )
                      ),
                    ),
                  )
                )
              ],
            )
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: chatBloc.chatStream,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return ListView.builder(
                  padding: EdgeInsets.only(top: 12.0),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        crossAxisAlignment: snapshot.data[index]['username'] == bloc.userInfo['username'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        mainAxisAlignment: snapshot.data[index]['username'] == bloc.userInfo['username'] ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: <Widget>[
                          if (snapshot.data[index]['username'] == bloc.userInfo['username'])
                            Spacer(),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: snapshot.data[index]['username'] == bloc.userInfo['username'] ? Radius.circular(18.0) : Radius.circular(0),
                                    bottomLeft: snapshot.data[index]['username'] == bloc.userInfo['username'] ? Radius.circular(18.0) : Radius.circular(0),
                                    topRight: snapshot.data[index]['username'] != bloc.userInfo['username'] ? Radius.circular(18.0) : Radius.circular(0),
                                    bottomRight: snapshot.data[index]['username'] != bloc.userInfo['username'] ? Radius.circular(18.0) : Radius.circular(0)
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                color: snapshot.data[index]['username'] == bloc.userInfo['username'] ? Colors.white : Color(int.parse('0xff${(args.data['service']['color']).split('#')[1]}')),
                              ),
                              padding: EdgeInsets.all(14.0),
                              child: Text(snapshot.data[index]['text'].toString(), style: TextStyle(color: snapshot.data[index]['username'] == bloc.userInfo['username'] ? Colors.black : Colors.white )),
                            ),
                          ),
                          if (snapshot.data[index]['username'] != bloc.userInfo['username'])
                            Spacer(),
                        ],
                      ),
                    );
                  }
              );
            } else {
              return Text('');
            }
          },
        )
      ),
    );
  }
}

class RideChatPageArguments {
  final Map<dynamic, dynamic> data;

  RideChatPageArguments(this.data);
}