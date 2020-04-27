import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pubnub_example/models/user_profile.dart';

class FriendsTab extends StatelessWidget {
  final Future<UserProfile> Function(String uuid) _fetchFriendProfile;
  final Future<void> Function(String uuid) _acceptInvitation;
  final List<String> _friends;
  final List<String> _invitations;
  final List<String> _activeUuids;
  final Map<String, UserProfile> _friendProfiles;
  final void Function(String uuid) _onClick;

  FriendsTab(
      this._fetchFriendProfile,
      this._friends,
      this._invitations,
      this._acceptInvitation,
      this._activeUuids,
      this._friendProfiles,
      this._onClick);

  Widget _friendEntry(BuildContext context, int index) {
    var uuid = _friends[index];
    var profileFuture = _fetchFriendProfile(uuid);

    var isActive = _activeUuids.contains(uuid);

    return FutureBuilder(
        initialData: _friendProfiles[uuid],
        builder:
            (BuildContext context, AsyncSnapshot<UserProfile> profileSnapshot) {
          if (profileSnapshot.data != null) {
            var profile = profileSnapshot.data;
            return ListTile(
                onTap: () => _onClick(uuid),
                title: Text(profile.displayName),
                subtitle: Text(profile.displayName),
                leading: Hero(
                    tag: index,
                    child: Stack(children: <Widget>[
                      CircleAvatar(
                          radius: 30,
                          backgroundColor: profile.avatar.color,
                          child: Text(profileSnapshot.data.avatar.emoji.code,
                              style: TextStyle(fontSize: 30))),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.lens,
                            size: 16,
                            color: isActive ? Colors.green : Colors.grey[300]),
                      ),
                    ])));
          }

          return Center(child: CircularProgressIndicator());
        },
        future: profileFuture);
  }

  Widget _invitationEntry(BuildContext context, int index) {
    var profileFuture = _fetchFriendProfile(_invitations[index]);

    return FutureBuilder(
        builder:
            (BuildContext context, AsyncSnapshot<UserProfile> profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var profile = profileSnapshot.data;

          return ListTile(
            title: Text(profile.displayName),
            subtitle: Text(profile.displayName),
            leading: Hero(
                tag: _invitations[index],
                child: CircleAvatar(
                    radius: 30,
                    backgroundColor: profile.avatar.color,
                    child: Text(profileSnapshot.data.avatar.emoji.code,
                        style: TextStyle(fontSize: 30)))),
            trailing: ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(icon: Icon(Icons.not_interested), onPressed: () {}),
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () => _acceptInvitation(_invitations[index]))
              ],
            ),
          );
        },
        future: profileFuture);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_invitations.length > 0)
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Text('Invitations',
                    style: Theme.of(context).textTheme.subtitle)),
          if (_invitations.length > 0)
            ListView.builder(
                shrinkWrap: true,
                itemCount: _invitations.length,
                itemBuilder: _invitationEntry),
          Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              child:
                  Text('Friends', style: Theme.of(context).textTheme.subtitle)),
          if (_friends.length > 0)
            ListView.builder(
                shrinkWrap: true,
                itemCount: _friends.length,
                itemBuilder: _friendEntry),
          if (_friends.length == 0)
            Center(
                child: Text('Invite some friends to start chatting!',
                    style: Theme.of(context).textTheme.caption))
        ]);
  }
}
