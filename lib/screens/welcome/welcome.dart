import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  void goToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Expanded(
          flex: 6,
          child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [...kElevationToShadow[12]]),
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Spacer(flex: 2),
                  Padding(
                      padding: EdgeInsets.all(30),
                      child: Image.asset('resources/logo_white.png')),
                  Spacer(flex: 1),
                  Text(
                    'Welcome to PubNub Flutter Demo App!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(flex: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text('Get started'),
                        color: Colors.white,
                        onPressed: () => goToLoginScreen(context),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ))),
      Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('resources/logo.png', height: 25),
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 20),
              Image.asset('resources/flutter_logo.png', height: 35)
            ],
          ))
    ]));
  }
}
