import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pubnub.dart';
import '../../models/models.dart';
import '../login/login.dart';
import './edit_profile.dart';
import './add_friend.dart';
import './profile.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

enum ChatView { conversations, friends, profile }

ChatView fromInt(int index) {
  switch (index) {
    case 0:
      return ChatView.conversations;
    case 1:
      return ChatView.friends;
    case 2:
      return ChatView.profile;
    default:
      return ChatView.conversations;
  }
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final pubnub = PubNubApp();
  TabController _tabController;
  ChatView _currentView = ChatView.profile;

  UserProfile _profile;
  LoginArguments _loginArguments;
  bool _isInitialized = false;

  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    super.initState();

    _tabController.addListener(() {
      setState(() {
        _currentView = fromInt(_tabController.index);
      });
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_isInitialized == false) {
      _loginArguments = ModalRoute.of(context).settings.arguments;

      pubnub.init(Keyset(
          subscribeKey: DotEnv().env['PUBNUB_SUBSCRIBE_KEY'],
          publishKey: DotEnv().env['PUBNUB_PUBLISH_KEY'],
          uuid: UUID(_loginArguments.uuid),
          authKey: _loginArguments.authKey));

      var myProfile = await pubnub.request('my-profile');

      if (myProfile['profile'] == null) {
        return logOut();
      } else {
        setState(() {
          _profile = UserProfile.fromJson(myProfile['profile']);
        });
      }

      setState(() {
        _isInitialized = true;
      });
    }
  }

  void logOut() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('identity');

    Navigator.of(context).pushReplacementNamed('/');
  }

  void editProfile() async {
    UserProfile res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileView(_profile),
        ));

    await pubnub.request('update-my-profile', res.toJson());

    setState(() {
      _profile = res;
    });
  }

  void addFriend() async {
    String email = await showDialog(
        context: context, builder: (context) => AddFriendModal());

    if (email == null) {
      return;
    }

    debugPrint(email);
  }

  Widget getTitle() {
    switch (_currentView) {
      case ChatView.conversations:
        return Text('Conversations');
      case ChatView.friends:
        return Text('Friends');
      case ChatView.profile:
        return Text('Profile');
      default:
        return Text('Whoops!');
    }
  }

  Widget getFAB() {
    switch (_currentView) {
      case ChatView.conversations:
        return Text('Conversations');
      case ChatView.friends:
        return FloatingActionButton(
            onPressed: addFriend, child: Icon(Icons.add));
      case ChatView.profile:
        return FloatingActionButton(
            onPressed: editProfile, child: Icon(Icons.edit));
      default:
        return Text('Whoops!');
    }
  }

  Widget buildConversationsTab(BuildContext context) {
    return Center(child: Text('Conversations'));
  }

  Widget buildFriendsTab(BuildContext context) {
    return Center(child: Text('Friends'));
  }

  Widget buildProfileTab(BuildContext context) {
    return ProfileTab(_profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: getTitle(),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.message)),
              Tab(icon: Icon(Icons.contacts)),
              Tab(icon: Icon(Icons.person))
            ],
            controller: _tabController,
          )),
      body: TabBarView(
        children: <Widget>[
          buildConversationsTab(context),
          buildFriendsTab(context),
          buildProfileTab(context),
        ],
        controller: _tabController,
      ),
      floatingActionButton: getFAB(),
    );
  }
}
