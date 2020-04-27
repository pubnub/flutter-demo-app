import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Map<String, String> _codeErrors = {
  'email_token_no_match': 'E-mail address and token don\'t match.'
};

class LoginArguments {
  final String email;
  final String uuid;
  final String authKey;

  const LoginArguments(this.email, this.uuid, this.authKey);
}

enum LoginState { initial, email, verification, authentication }

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String _error;
  LoginState _currentState = LoginState.initial;
  String _email;

  @override
  void initState() {
    super.initState();

    checkForIdentity();
  }

  void checkForIdentity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('identity')) {
      var identity = prefs.getStringList('identity');

      Navigator.pushNamedAndRemoveUntil(
          context, '/chat', (route) => route.isFirst,
          arguments: LoginArguments(identity[0], identity[1], identity[2]));
    } else {
      setState(() {
        _currentState = LoginState.email;
      });
    }
  }

  void verifyEmail(String email) async {
    setState(() {
      _isLoading = true;
    });

    var response = await http.post(
        'https://ps.pndsn.com/v1/blocks/sub-key/sub-c-e6ef4f4a-8195-11ea-8dff-bafe0457d467/get-token',
        headers: {'Content-Type': 'application/json'},
        body: '{"email": "$email"}');

    var result = json.decode(response.body);

    if (result['success']) {
      setState(() {
        _isLoading = false;
        _email = email;
        _currentState = LoginState.verification;
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Sending the mail failed. Please try again later.';
      });
    }
  }

  void verifyCode(String code) async {
    setState(() {
      _currentState = LoginState.authentication;
      _error = null;
      _isLoading = true;
    });

    var response = await http.post(
        'https://ps.pndsn.com/v1/blocks/sub-key/sub-c-e6ef4f4a-8195-11ea-8dff-bafe0457d467/login',
        headers: {'Content-Type': 'application/json'},
        body: '{"email":"$_email", "code":"${code.split('').join(' ')}"}');

    var result = json.decode(response.body);

    if (result['error'] != null) {
      setState(() {
        _isLoading = false;
        _currentState = LoginState.verification;
        _error = result['error'];
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        _isLoading = false;
      });

      prefs.setStringList(
          'identity', [result['email'], result['uuid'], result['authKey']]);

      Timer(Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/chat', (route) => route.isFirst,
            arguments: LoginArguments(
                result['email'], result['uuid'], result['authKey']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Getting Started'),
        ),
        body: getCurrentView(context));
  }

  Widget getCurrentView(BuildContext context) {
    switch (_currentState) {
      case LoginState.initial:
        return buildInitialView(context);
      case LoginState.email:
        return buildEmailView(context);
      case LoginState.verification:
        return buildVerificationView(context);
      case LoginState.authentication:
        return buildAuthenticationView(context);
      default:
        throw new Exception('unreachable state');
    }
  }

  Widget buildInitialView(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildAuthenticationView(BuildContext context) {
    return Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Icon(Icons.check, color: Colors.green, size: 60));
  }

  Widget buildVerificationView(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login code has been sent to $_email',
              style: TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              _error != null
                  ? _codeErrors[_error]
                  : 'Check your spam folder if you cannot find it.',
              style: TextStyle(
                  fontSize: 16.0,
                  color: _error != null
                      ? Colors.red
                      : Theme.of(context).textTheme.caption.color),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            PinCodeTextField(
              textInputType: TextInputType.number,
              length: 6,
              controller: _codeController,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onChanged: (value) {},
              onCompleted: (value) => verifyCode(value),
            )
          ],
        ),
      ),
    );
  }

  Widget buildEmailView(BuildContext context) {
    final TextEditingController _emailController = new TextEditingController();

    return Center(
      child: Padding(
        padding: EdgeInsets.all(36.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Register or login using your e-mail.\nWe will send you a mail with your login code.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0)),
            Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: TextField(
                    controller: _emailController,
                    textCapitalization: TextCapitalization.none,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        hintText: 'E-mail address',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _emailController.clear();
                            }),
                        errorText: _error,
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0)))),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      textTheme: ButtonTextTheme.primary,
                      onPressed: () {
                        verifyEmail(_emailController.value.text);
                      },
                      child: Text('Send the code')),
            )
          ],
        ),
      ),
    );
  }
}
