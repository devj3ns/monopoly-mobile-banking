import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    this.currentGameId,
  });

  final String id;
  final String name;
  final String? currentGameId;

  static const none = User(id: '', name: '');

  @override
  List<Object?> get props => [
        id,
        name,
        currentGameId,
      ];

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['uid'],
        name: json['name'],
        currentGameId: json['currentGameId'],
      );

  Map<String, dynamic> toJson() => {
        'uid': id,
        'name': name,
        'currentGameId': currentGameId,
      };
}

extension UserExtensions on User {
  bool get isNone => this == User.none;
}
