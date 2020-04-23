import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

class ProfileTab extends StatelessWidget {
  final UserProfile _profile;
  ProfileTab(this._profile);

  void logOut(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('identity');

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return Center(child: CircularProgressIndicator());

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 30),
        CircleAvatar(
            radius: 40,
            backgroundColor: _profile.avatar.color,
            child: Text(_profile.avatar.emoji.code,
                style: TextStyle(fontSize: 40))),
        SizedBox(height: 15),
        Text(_profile.displayName ?? 'anonymous',
            style: TextStyle(fontSize: 20)),
        Spacer(flex: 3),
        Divider(),
        RaisedButton(
          child: Text('Log out', style: TextStyle(color: Colors.white)),
          onPressed: () => logOut(context),
        ),
        Spacer(flex: 1),
      ],
    );
  }
}
