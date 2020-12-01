import 'package:flutter/material.dart';

/*defaultButton(BuildContext context, String text, Function onPressed) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      height: 54.0,
      child: RaisedButton(
        elevation: 4,
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18.0),),
      )
  );
}*/

Widget defaultButton(width, String text, Function onPressed, {Color color = Colors.black, Color textColor = Colors.white}) {
  return SizedBox(
      width: width,
      height: 48.0,
      child: RaisedButton(
        color: color,
        elevation: 4,
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 17.0, color: textColor),),
      )
  );
}

Widget defaultButtonOutline(width, String text, Function onPressed) {
  return SizedBox(
      width: width,
      height: 48.0,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.black)
        ),
        color: Colors.white,
        textColor: Colors.black,
        elevation: 4,
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18.0),),
      )
  );
}