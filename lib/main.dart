import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

import 'screens/chat/chat.dart';
import 'screens/login/login.dart';
import 'screens/welcome/welcome.dart';

void main() async {
  await DotEnv().load('.env');

  runApp(App());
}

final Color pubnubRed = Color.fromRGBO(183, 51, 49, 1);

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PubNub Flutter Demo App',
      theme: ThemeData(
          primaryColor: pubnubRed,
          buttonColor: pubnubRed,
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: pubnubRed)),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/chat': (context) => ChatScreen()
      },
    );
  }
}
