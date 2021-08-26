import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Player extends Equatable {
  const Player({
    required this.userId,
    required this.name,
    required this.balance,
    required this.color,
  });

  @override
  List<Object> get props => [userId, name, balance, color];

  /// The user id from firebase auth.
  final String userId;

  /// The users name which is stored in the database.
  final String name;

  /// The players balance for this game.
  final int balance;

  /// The color the player got when he joined.
  final Color color;

  /// Returns a new instance with an updated balance.
  Player addMoney(int amount) {
    return Player(
        userId: userId, name: name, balance: balance + amount, color: color);
  }

  /// Returns a new instance with an updated balance.
  Player subtractMoney(int amount) {
    return Player(
        userId: userId, name: name, balance: balance - amount, color: color);
  }

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      userId: json['userId'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'balance': balance,
      'color': color.value
    };
  }
}
