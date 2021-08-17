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

  static const none = User(id: '', name: ''); //todo: remove this?!

  @override
  List<Object?> get props => [id, name, currentGameId];

  static User fromJson(
    Map<String, dynamic> json, {
    required String snapshotId,
  }) =>
      User(
        id: snapshotId,
        name: json['name'] as String,
        currentGameId: json['currentGameId'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'currentGameId': currentGameId,
      };
}

extension UserExtensions on User {
  bool get isNone => this == User.none;
}
