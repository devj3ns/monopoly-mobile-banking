import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../banking_repository.dart';

class Player extends Equatable {
  const Player({
    required this.userId,
    required this.name,
    required this.balance,
    required this.color,
    required this.bankruptTimestamp,
    required this.isGameCreator,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        balance,
        color,
        bankruptTimestamp,
        isGameCreator,
      ];

  /// The user id from firebase auth.
  final String userId;

  /// The users name which is stored in the database.
  final String name;

  /// The players balance for this game.
  final int balance;

  /// The color the player got when he joined.
  final Color color;

  /// The time at which the player went bankrupt. If null he is not yet bankrupt.
  final DateTime? bankruptTimestamp;

  /// Whether this player created the game.
  final bool isGameCreator;

  /// The place the player made in this game.
  ///
  /// Should only be called when someone won and the game is over.
  int place(Game game) {
    if (game.winner == this) return 1;

    assert(isBankrupt);

    final bankruptPlayerSorted = game.bankruptPlayers.asList().toList()
      ..sort((a, b) => a.bankruptTimestamp!.compareTo(b.bankruptTimestamp!));

    return game.players.size - bankruptPlayerSorted.indexOf(this);
  }

  /// The time between the start of the game and the time the player went bankrupt.
  ///
  /// This should only be called when the player is bankrupt.
  Duration bankruptTime(Game game) {
    assert(game.startingTimestamp != null);
    assert(isBankrupt);
    assert(bankruptTimestamp != null);

    return bankruptTimestamp!.difference(game.startingTimestamp!);
  }

  /// Whether the players balance is 0 or below.
  bool get isBankrupt {
    return balance <= 0;
  }

  Player copyWith({int? balance, DateTime? bankruptTimestamp}) {
    return Player(
      userId: userId,
      name: name,
      balance: balance ?? this.balance,
      bankruptTimestamp: bankruptTimestamp ?? this.bankruptTimestamp,
      color: color,
      isGameCreator: isGameCreator,
    );
  }

  /// Returns a new instance with an updated balance.
  Player addMoney(int amount) {
    return copyWith(balance: balance + amount);
  }

  /// Returns a new instance with an updated balance.
  Player subtractMoney(int amount) {
    return copyWith(balance: balance - amount);
  }

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      userId: pick(json, 'userId').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      balance: pick(json, 'balance').asIntOrThrow(),
      color: Color(pick(json, 'color').asIntOrThrow()),
      bankruptTimestamp: pick(json, 'wentBankruptTimestamp')
          .asFirestoreTimeStampOrNull()
          ?.toDate(),
      isGameCreator: pick(json, 'isGameCreator').asBoolOrFalse(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'balance': balance,
      'color': color.value,
      'wentBankruptTimestamp': bankruptTimestamp,
      'isGameCreator': isGameCreator,
    };
  }
}
