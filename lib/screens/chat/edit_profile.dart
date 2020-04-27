import 'package:emoji_picker/emoji_picker.dart' as ep;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

import '../../models/models.dart';

class EditProfileView extends StatefulWidget {
  final UserProfile _profile;

  EditProfileView(this._profile);

  @override
  _EditProfileViewState createState() => _EditProfileViewState(_profile);
}

class _EditProfileViewState extends State<EditProfileView> {
  final EmojiParser _emoji = EmojiParser();
  final TextEditingController _displayNameController;
  UserProfile _profile;
  _EditProfileViewState(this._profile)
      : _displayNameController =
            TextEditingController(text: _profile.displayName);

  void changeEmoji() async {
    showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) => Column(children: <Widget>[
              Spacer(flex: 1),
              ep.EmojiPicker(
                  columns: 7,
                  rows: 6,
                  onEmojiSelected: (emoji, category) {
                    setState(() {
                      _profile = _profile.clone(
                          avatar: _profile.avatar
                              .clone(emoji: _emoji.getEmoji(emoji.emoji)));
                    });
                  })
            ]));
  }

  void changeColor() async {
    var currentColor = _profile.avatar.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: SlidePicker(
            onColorChanged: (color) => currentColor = color,
            pickerColor: _profile.avatar.color.withAlpha(255),
            enableAlpha: false,
            paletteType: PaletteType.hsl,
            showLabel: false,
          ),
        ),
        actions: <Widget>[
          FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
              }),
          FlatButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _profile = _profile.clone(
                      avatar: _profile.avatar.clone(color: currentColor));
                  Navigator.of(context, rootNavigator: true).pop();
                });
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            Navigator.pop(context,
                _profile.clone(displayName: _displayNameController.value.text));
          },
        ),
        body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _profile.avatar.color,
                          child: Text(_profile.avatar.emoji.code,
                              style: TextStyle(fontSize: 40)),
                        ),
                        SizedBox(width: 30),
                        Column(
                          children: <Widget>[
                            FlatButton(
                                onPressed: changeColor,
                                child: Text('Change color')),
                            FlatButton(
                                onPressed: changeEmoji,
                                child: Text('Change emoji'))
                          ],
                        )
                      ]),
                  SizedBox(height: 15),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: TextField(
                        controller: _displayNameController,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            labelText: 'Display name',
                            labelStyle: TextStyle(fontSize: 20)),
                      )),
                ],
              ))
            ]));
  }
}
