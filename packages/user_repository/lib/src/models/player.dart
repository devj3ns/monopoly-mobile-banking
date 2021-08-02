import 'package:equatable/equatable.dart';

class Player extends Equatable {
  const Player({
    required this.userId,
    required this.name,
    required this.balance,
  });

  @override
  List<Object> get props => [userId, name, balance];

  /// The user id from firebase auth.
  final String userId;

  /// The users name which is stored in the database.
  final String name;

  /// The players balance for this game.
  final int balance;

  /// Returns a new instance with an updated balance.
  Player addMoney(int amount) {
    return Player(userId: userId, name: name, balance: balance + amount);
  }

  /// Returns a new instance with an updated balance.
  Player subtractMoney(int amount) {
    return Player(userId: userId, name: name, balance: balance - amount);
  }

  static Player fromJson(Map<String, dynamic> json) {
    return Player(
      userId: json['userId'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'balance': balance,
    };
  }
}
