import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pubnub_example/models/user_profile.dart';
import '../../pubnub.dart';

class ConversationView extends StatefulWidget {
  final Conversation _conversation;
  final UserProfile _theirProfile;
  final UserProfile _userProfile;
  final PubNubApp _pubnub;

  ConversationView(
      this._conversation, this._userProfile, this._theirProfile, this._pubnub);

  @override
  _ConversationViewState createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  List<ChatMessage> _messages = [];

  @override
  initState() {
    super.initState();

    widget._pubnub.subs.me.messages.where((env) {
      return env.uuid?.value == widget._conversation.them;
    }).listen((env) {
      if (mounted)
        setState(() {
          _messages.add(ChatMessage(text: env.payload, user: _them));
          _messages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
        });

      scrollToTop();
    });

    getHistory();
  }

  void scrollToTop() async {
    await Future.delayed(Duration(milliseconds: 200));

    _controller.animateTo(_controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 100), curve: ElasticInOutCurve());
  }

  void getHistory() async {
    widget._conversation.reset();
    await widget._conversation.more();

    if (mounted)
      setState(() {
        _messages.addAll(widget._conversation.from.messages.map((msg) =>
            ChatMessage(
                text: msg.contents,
                user: _user,
                createdAt: msg.timetoken.toDateTime())));

        _messages.addAll(widget._conversation.to.messages.map((msg) =>
            ChatMessage(
                text: msg.contents,
                user: _them,
                createdAt: msg.timetoken.toDateTime())));

        _messages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
      });

    scrollToTop();
  }

  Future<void> sendMessage(ChatMessage msg) async {
    await widget._pubnub.pubnub.publish(
        '${widget._conversation.them}.${widget._conversation.me}', msg.text);

    setState(() {
      _messages.add(msg);
      _messages.sort((m1, m2) => m1.createdAt.compareTo(m2.createdAt));
    });
  }

  Widget _avatarBuilder(ChatUser user) {
    UserProfile profile;
    if (user.uid == widget._conversation.me) {
      profile = widget._userProfile;
    } else {
      profile = widget._theirProfile;
    }

    return CircleAvatar(
        radius: 20,
        backgroundColor: profile.avatar.color,
        child: Text(profile.avatar.emoji.code, style: TextStyle(fontSize: 20)));
  }

  ChatUser get _user => ChatUser(
      uid: widget._conversation.me,
      name: widget._userProfile.displayName,
      avatar: 'not used');

  ChatUser get _them => ChatUser(
      uid: widget._conversation.them,
      name: widget._theirProfile.displayName,
      avatar: 'not used');

  ScrollController _controller =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget._theirProfile.displayName)),
        body: DashChat(
          user: _user,
          avatarBuilder: _avatarBuilder,
          onSend: sendMessage,
          messages: _messages,
          scrollToBottom: false,
          scrollController: _controller,
        ));
  }
}
