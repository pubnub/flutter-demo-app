import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

import './model.dart';

final _emoji = EmojiParser();

class UserAvatar implements Model {
  final Emoji emoji;
  final Color color;

  const UserAvatar._(this.emoji, this.color);

  factory UserAvatar.normal() =>
      UserAvatar._(_emoji.getName('no_mouth'), Color.fromRGBO(255, 0, 0, 1));

  @override
  UserAvatar clone({Emoji emoji, Color color}) {
    return UserAvatar._(emoji ?? this.emoji, color ?? this.color);
  }

  factory UserAvatar.fromJson([dynamic object = const {}]) => UserAvatar._(
      _emoji.getName(object['emoji'] ?? 'no_mouth'),
      Color(object['color'] ?? Colors.red.value));

  @override
  Map<String, dynamic> toJson() => {'emoji': emoji.name, 'color': color.value};
}

class UserProfile implements Model {
  final String displayName;
  final UserAvatar avatar;

  const UserProfile._({this.displayName, this.avatar});

  @override
  UserProfile clone({String displayName, UserAvatar avatar}) {
    return UserProfile._(
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar.clone());
  }

  factory UserProfile.fromJson(dynamic object) => UserProfile._(
      displayName: object['displayName'],
      avatar: UserAvatar.fromJson(object['avatar']));

  @override
  Map<String, dynamic> toJson() =>
      {'displayName': displayName, 'avatar': avatar.toJson()};
}
