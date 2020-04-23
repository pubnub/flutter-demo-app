import 'package:flutter/material.dart';

class AddFriendModal extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Card(
            margin: EdgeInsets.all(30),
            child: Container(
                padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Add a Friend',
                        style: Theme.of(context).textTheme.title),
                    SizedBox(height: 15),
                    Text(
                        'If your friend doesn\'t use our application, we will send him an invite e-mail.',
                        style: Theme.of(context).textTheme.caption),
                    SizedBox(height: 15),
                    TextField(
                      decoration: InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    SizedBox(height: 15),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: <Widget>[
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                        RaisedButton(
                          child: Text('Invite'),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop(_emailController.value.text);
                          },
                        )
                      ],
                    )
                  ],
                )))
      ],
    );
  }
}
