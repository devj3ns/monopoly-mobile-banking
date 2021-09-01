import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'game.dart';

class Player extends Equatable {
  const Player({
    required this.userId,
    required this.name,
    required this.balance,
    required this.color,
    required this.bankruptTimestamp,
  });

  @override
  List<Object?> get props => [userId, name, balance, color, bankruptTimestamp];

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
    assert(isBankrupt);

    return bankruptTimestamp!.difference(game.startingTimestamp);
  }

  /// Whether the players balance is 0 or below.
  bool get isBankrupt {
    assert(bankruptTimestamp != null);

    return balance <= 0;
  }

  Player copyWith({int? balance, DateTime? bankruptTimestamp}) {
    return Player(
      userId: userId,
      name: name,
      balance: balance ?? this.balance,
      bankruptTimestamp: bankruptTimestamp ?? this.bankruptTimestamp,
      color: color,
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
      userId: json['userId'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
      color: Color(json['color'] as int),
      bankruptTimestamp: json['wentBankruptTimestamp'] == null
          ? null
          : (json['wentBankruptTimestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'balance': balance,
      'color': color.value,
      'wentBankruptTimestamp': bankruptTimestamp,
    };
  }
}
