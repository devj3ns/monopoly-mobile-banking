import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    this.currentGameId,
    required this.wins,
  });

  final String id;
  final String name;
  final String? currentGameId;
  final int wins;

  static const none = User(id: '', name: '', wins: 0); //todo: remove this?!

  @override
  List<Object?> get props => [id, name, currentGameId, wins];

  static User fromJson(
    Map<String, dynamic> json, {
    required String snapshotId,
  }) =>
      User(
        id: snapshotId,
        name: json['name'] as String,
        currentGameId: json['currentGameId'] as String?,
        wins: json['wins'] as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'currentGameId': currentGameId,
        'wins': wins,
      };
}

extension UserExtensions on User {
  bool get isNone => this == User.none;
}
