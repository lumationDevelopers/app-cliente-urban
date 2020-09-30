import 'package:carousel_slider/carousel_slider.dart';
import 'package:client/widgets/defaultButton.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final List slideMessage = [
    'Solicita viajes y un conductor cercano te transportará a tu destino',
    'Elige si prefieres pagar con tarjeta o con efectivo',
    '¿Eres mujer? Solicita un viaje con Urban Pink, un servicio de mujeres para mujeres'
  ];

  final List slideTitle = [
    'Solicita viajes',
    'Paga fácilmente',
    'Urban Pink'
  ];

  int currentSlide = 0;

  void slidePageChanged(int page, event) {
    setState(() {
      currentSlide = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(slideTitle[currentSlide], style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold))
              ],
            ),
            CarouselSlider(
              options: CarouselOptions(height: 300.0, onPageChanged: slidePageChanged, autoPlay: true, autoPlayAnimationDuration: Duration(seconds: 2)),
              items: [1,2,3].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: double.infinity,
                        child: Image.asset('assets/onboarding-$i.png')
                    );
                  },
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: 82.0,
                  child: Text(slideMessage[currentSlide], overflow: TextOverflow.clip, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0, fontFamily: 'Lato-light')),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 32.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  defaultButton(
                    MediaQuery.of(context).size.width * 0.40,
                    'Regístrate',
                    () => Navigator.of(context).pushNamed('auth/register')
                  ),
                  Spacer(),
                  defaultButtonOutline(
                       MediaQuery.of(context).size.width * 0.40,
                      'Inicia sesión',
                      () => Navigator.of(context).pushNamed('auth/login')
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
