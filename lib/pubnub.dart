import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';
import 'package:uuid/uuid.dart';
import 'package:pubnub/src/dx/subscribe/extensions/keyset.dart';

class AppChannels {
  final Channel system;

  AppChannels(PubNub pubnub, UUID uuid)
      : system = pubnub.channel('system.${uuid.value}');
}

class AppSubscriptions {
  Subscription system;
  Subscription friends;
  Subscription me;
}

class Conversation {
  PaginatedChannelHistory from;
  PaginatedChannelHistory to;

  String me;
  String them;

  List<Message> get messages => ([...from.messages, ...to.messages]
        ..sort((m1, m2) => m1.timetoken.value.compareTo(m2.timetoken.value)))
      .reversed
      .toList();

  Conversation(this.from, this.to, this.me, this.them);

  Future<void> more() async {
    await from.more();
    await to.more();
  }

  void reset() {
    from.reset();
    to.reset();
  }
}

class PubNubApp {
  static final _instance = PubNubApp._internal();
  factory PubNubApp() => _instance;

  PubNub _pubnub = PubNub();
  PubNub get pubnub => _pubnub;

  PubNubApp._internal();

  AppChannels channels;
  AppSubscriptions subs = AppSubscriptions();

  bool _isInitialized = false;

  void init(Keyset keyset) {
    debugPrint('trying to init');
    if (_isInitialized == false) {
      _isInitialized = true;
      _pubnub.keysets.add(keyset, name: 'default', useAsDefault: true);

      channels = AppChannels(_pubnub, keyset.uuid);

      subs.system = channels.system.subscribe();
      subs.me =
          pubnub.subscribe(channels: {'${keyset.uuid}.*'}, withPresence: true);

      // keyset.subscriptionManager.messages.listen((msg) {
      //   debugPrint('$msg');
      // });

      debugPrint('Subscribing to self: ${keyset.uuid}.* ');
    } else {
      _pubnub.keysets.remove('default');
      subs.system.unsubscribe();
      _isInitialized = false;
      init(keyset);
    }
  }

  Future<dynamic> request(String type, [dynamic payload]) async {
    var requestId = Uuid().v4();

    var result = subs.system.messages
        .firstWhere((envelope) => envelope.payload['responseId'] == requestId);

    channels.system.publish({
      'requestId': requestId,
      'type': type,
      if (payload != null) 'payload': payload
    });

    return (await result).payload;
  }

  Subscription get self => subs.me;

  Future<void> announceFriends(String myUuid, List<String> uuids) async {
    if (subs.friends != null) {
      subs.friends.unsubscribe();
    }

    var channels = uuids.map((uuid) => '$uuid.$myUuid').toSet();

    await pubnub.announceHeartbeat(channels: channels, heartbeat: 60);
  }

  Future<List<String>> activeFriends(String myUuid, List<String> uuids) async {
    var result = await pubnub.hereNow(
        channels: uuids.map((uuid) => '$myUuid.$uuid').toSet());

    return uuids.where((uuid) {
      var channelOccupation = result.channels['$myUuid.$uuid'];

      return channelOccupation.uuids.containsKey(uuid);
    }).toList();
  }

  Conversation getConversation(String myUuid, String theirUuid) {
    var toChannel = pubnub.channel('$myUuid.$theirUuid');
    var fromChannel = pubnub.channel('$theirUuid.$myUuid');

    var toHistory = toChannel.history(chunkSize: 50);
    var fromHistory = fromChannel.history(chunkSize: 50);

    var conversation = Conversation(fromHistory, toHistory, myUuid, theirUuid);

    return conversation;
  }
}
