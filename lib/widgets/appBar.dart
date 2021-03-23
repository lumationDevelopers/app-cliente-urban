import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

urbanAppBar(BuildContext context, String title, bool modal) {

  final Widget _leading = modal ? IconButton(
    icon: Icon(Icons.close, size: 46.0),
    onPressed: () => Navigator.of(context).pop(),
  ) : InkWell(
    onTap: () => Navigator.of(context).pop(),
    child: Container(
      margin: EdgeInsets.only(left: 14.0),
      child: SvgPicture.asset('assets/back-icon.svg', color: Colors.white,),
    ),
  );

  return AppBar(
      elevation: 0,
      leading: _leading,
      bottom: PreferredSize(
          child: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Padding(
              padding: EdgeInsets.only(bottom: 28.0),
              child: Text(title, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold,))
            ),
          ), preferredSize: Size.fromHeight(68.0))
  );
}