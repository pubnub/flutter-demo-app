import 'package:pubnub/pubnub.dart';
import 'package:uuid/uuid.dart';

class AppChannels {
  final Channel system;

  AppChannels(PubNub pubnub, UUID uuid)
      : system = pubnub.channel('system.${uuid.value}');
}

class AppSubscriptions {
  Subscription system;
}

class PubNubApp {
  static final _instance = PubNubApp._internal();
  factory PubNubApp() => _instance;

  PubNub _pubnub = PubNub();

  PubNubApp._internal();

  AppChannels channels;
  AppSubscriptions _subs = AppSubscriptions();

  bool _isInitialized = false;

  void init(Keyset keyset) {
    if (_isInitialized == false) {
      _isInitialized = true;
      _pubnub.keysets.add(keyset, name: 'default', useAsDefault: true);

      channels = AppChannels(_pubnub, keyset.uuid);

      _subs.system = channels.system.subscribe();
    }
  }

  Future<dynamic> request(String type, [dynamic payload]) async {
    var requestId = Uuid().v4();

    var result = _subs.system.messages
        .firstWhere((envelope) => envelope.payload['responseId'] == requestId);

    channels.system.publish({
      'requestId': requestId,
      'type': type,
      if (payload != null) 'payload': payload
    });

    return (await result).payload;
  }
}
