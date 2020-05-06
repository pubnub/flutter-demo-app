import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_pubnub_example/screens/chat/friends.dart';
import 'package:pubnub/pubnub.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pubnub.dart';
import '../../models/models.dart';
import '../login/login.dart';
import './edit_profile.dart';
import './add_friend.dart';
import './profile.dart';
import 'conversation.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

enum ChatView { friends, profile }

ChatView fromInt(int index) {
  switch (index) {
    case 0:
      return ChatView.friends;
    case 1:
      return ChatView.profile;
    default:
      return ChatView.friends;
  }
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final pubnub = PubNubApp();
  String _uuid;
  TabController _tabController;
  ChatView _currentView = ChatView.profile;
  GlobalKey _scaffoldingKey = GlobalKey();

  List<String> _friends = [];
  List<String> _activeUuids = [];
  List<String> _invitations = [];
  List<Conversation> _conversations = [];

  Map<String, UserProfile> _friendProfiles = {};

  UserProfile _profile;
  bool _isInitialized = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, initialIndex: 1, vsync: this);
    super.initState();

    _tabController.addListener(() {
      setState(() {
        _currentView = fromInt(_tabController.index);
      });

      if (fromInt(_tabController.index) == ChatView.friends) {
        fetchFriends();
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_isInitialized == false) {
      LoginArguments _loginArguments =
          ModalRoute.of(context).settings.arguments;

      await pubnub.init(Keyset(
          subscribeKey: DotEnv().env['PUBNUB_SUBSCRIBE_KEY'],
          publishKey: DotEnv().env['PUBNUB_PUBLISH_KEY'],
          uuid: UUID(_loginArguments.uuid),
          authKey: _loginArguments.authKey));

      var myProfile;
      try {
        myProfile = await pubnub.request('my-profile');
      } catch (e) {
        debugPrint(e.toString());
        return;
      }

      if (myProfile['payload'] == null) {
        return logOut();
      } else {
        setState(() {
          _profile = UserProfile.fromJson(myProfile['payload']);
        });
      }

      pubnub.self.presence.listen((e) {
        debugPrint('SELF: ${e.action} ${e.uuid}');
      });

      setState(() {
        _uuid = _loginArguments.uuid;
        _isInitialized = true;
      });

      var invitations = await pubnub.request('my-invitations');

      setState(() {
        _invitations = (invitations['payload'] ?? []).cast<String>();
      });

      fetchFriends();
      getConversations();
    }
  }

  void openConversation(Conversation conversation) async {
    var me = _profile;
    var them = _friendProfiles[conversation.them];

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConversationView(conversation, me, them, pubnub),
        ));
  }

  void fetchFriends() async {
    var friends = await pubnub.request('my-friends');

    if (friends['payload'] != null) {
      setState(() {
        _friends = friends['payload'].cast<String>();
      });
    } else {
      return;
    }

    await pubnub.announceFriends(_uuid, _friends);

    await getConversations();

    for (var friend in _friends) {
      await _fetchFriendProfile(friend);
    }

    var activeUuids = await pubnub.activeFriends(_uuid, _friends);

    setState(() {
      _activeUuids = activeUuids;
    });
  }

  void logOut() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('identity');

    Navigator.of(context).pushReplacementNamed('/');
  }

  void editProfile() async {
    var profile = _profile;

    setState(() {
      _profile = null;
    });

    UserProfile res = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileView(profile),
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

    await pubnub.request('invite-friend', email);
  }

  Future<void> acceptInvitation(String uuid) async {
    var response = await pubnub.request('accept-invitation', uuid);

    if (response['payload'] == null) {
      ScaffoldState scaffold = _scaffoldingKey.currentState;
      scaffold.showSnackBar(SnackBar(
          content: Text('An error has occured. Try again later.'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              scaffold.hideCurrentSnackBar();
            },
          )));
    } else {
      setState(() {
        _invitations = response['payload'].cast<String>();
      });

      fetchFriends();
    }
  }

  Future<UserProfile> _fetchFriendProfile(String uuid) async {
    var cached = _friendProfiles[uuid];

    if (cached != null) {
      return cached;
    }

    var res = await pubnub.request('get-profile', uuid);

    var profile = UserProfile.fromJson(res['payload']);

    _friendProfiles[uuid] = profile;

    return profile;
  }

  Future<void> getConversations() async {
    var convs =
        _friends.map((uuid) => pubnub.getConversation(_uuid, uuid)).toList();

    for (var convo in convs) {
      await convo.more();
    }

    setState(() {
      _conversations = convs;
    });
  }

  Widget getTitle() {
    switch (_currentView) {
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

  Widget buildFriendsTab(BuildContext context) {
    return FriendsTab(_fetchFriendProfile, _friends, _invitations,
        acceptInvitation, _activeUuids, _friendProfiles, (uuid) {
      var convo = _conversations.firstWhere((convo) => convo.them == uuid);
      openConversation(convo);
    });
  }

  Widget buildProfileTab(BuildContext context) {
    return ProfileTab(_profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldingKey,
      appBar: AppBar(
          title: getTitle(),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.contacts)),
              Tab(icon: Icon(Icons.person))
            ],
            controller: _tabController,
          )),
      body: TabBarView(
        children: <Widget>[
          buildFriendsTab(context),
          buildProfileTab(context),
        ],
        controller: _tabController,
      ),
      floatingActionButton: getFAB(),
    );
  }
}
