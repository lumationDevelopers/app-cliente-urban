import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';

class Utils {
  messageDialog(BuildContext context, String title, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  Future<bool> confirmDialog(BuildContext context, String title, String message, { String acceptText = 'Aceptar', String cancelText = 'Cancelar' }) async {
    bool response = false;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop();
                  response = false;
                },
              ),
              FlatButton(
                child: Text(acceptText),
                onPressed: () {
                  Navigator.of(context).pop();
                  response = true;
                },
              ),
            ],
          );
        }
    );

    return response;
  }

  Future<Map> inputDialog(BuildContext context, String title, { String acceptText = 'Aceptar', String cancelText = 'Cancelar' }) async {
    String message = '';
    bool response = false;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              child: TextField(
                onChanged: (v) {
                  message = v;
                },
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(cancelText),
                onPressed: () {
                  Navigator.of(context).pop();
                  response = false;
                },
              ),
              FlatButton(
                child: Text(acceptText),
                onPressed: () {
                  Navigator.of(context).pop();
                  response = true;
                },
              ),
            ],
          );
        }
    );

    return {
      "response": response,
      "message": message
    };
  }

  selectDialog(BuildContext context, String title, List<dynamic> options) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      child: ListTile(
                          leading: options[index]['leading'],
                          title: options[index]['title']
                      ),
                    )
                  );
                },
              )
            ),
          );
        }
    );
  }

  loadingDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              color: Colors.white
            ),
            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.40, horizontal: MediaQuery.of(context).size.height * 0.15),
            height: 38.0,
            width: 38.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 28.0,
                  height: 28.0,
                  child: Theme(
                    data: Theme.of(context).copyWith(accentColor: Colors.black),
                    child: new CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  closeDialog(BuildContext context) => Navigator.of(context).pop();
}