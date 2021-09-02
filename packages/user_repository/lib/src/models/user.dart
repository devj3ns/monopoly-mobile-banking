import 'package:equatable/equatable.dart';
import 'package:fleasy/fleasy.dart';
import 'package:deep_pick/deep_pick.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    this.currentGameId,
    required this.wins,
  }) : assert(currentGameId != '');

  final String id;
  final String name;
  final String? currentGameId;
  final int wins;

  static const none = User(id: '', name: '', wins: 0);

  @override
  List<Object?> get props => [id, name, currentGameId, wins];

  static User fromJson(
    Map<String, dynamic> json, {
    required String snapshotId,
  }) =>
      User(
        id: snapshotId,
        name: pick(json, 'name').asStringOrThrow(),
        currentGameId: pick(json, 'currentGameId').asStringOrNull(),
        wins: pick(json, 'wins').asIntOrThrow(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'currentGameId': currentGameId,
        'wins': wins,
      };

  User copyWith({
    String? name,
    String? Function()? currentGameId,
    int? wins,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      currentGameId:
          currentGameId != null ? currentGameId() : this.currentGameId,
      wins: wins ?? this.wins,
    );
  }
}

extension UserExtensions on User {
  bool get isNone => this == User.none;

  bool get hasUsername => name.isNotBlank;
}
