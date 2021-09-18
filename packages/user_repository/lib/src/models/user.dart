import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:fleasy/fleasy.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.playedGamesIds,
    required this.gamesWon,
    this.photoURL,
    this.currentGameId,
  }) : assert(currentGameId != '');

  final String id;
  final String name;
  final List<String> playedGamesIds;
  final int gamesWon;
  final String? photoURL;
  final String? currentGameId;

  static const none = User(
    id: '',
    name: '',
    playedGamesIds: [],
    gamesWon: 0,
    photoURL: null,
    currentGameId: null,
  );

  @override
  List<Object?> get props => [
        id,
        name,
        playedGamesIds,
        gamesWon,
        photoURL,
        currentGameId,
      ];

  static User fromJson(
    Map<String, dynamic> json, {
    required String snapshotId,
  }) =>
      User(
        id: snapshotId,
        name: pick(json, 'name').asStringOrThrow(),
        playedGamesIds: pick(json, 'playedGamesIds')
            .asListOrThrow((gameId) => gameId.asStringOrThrow()),
        gamesWon: pick(json, 'gamesWon').asIntOrThrow(),
        photoURL: pick(json, 'photoURL').asStringOrNull(),
        currentGameId: pick(json, 'currentGameId').asStringOrNull(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'playedGamesIds': playedGamesIds,
        'gamesWon': gamesWon,
        'photoURL': photoURL,
        'currentGameId': currentGameId,
      };

  User copyWith({
    String? id,
    String? name,
    List<String>? playedGamesIds,
    int? gamesWon,
    String? photoURL,
    String? Function()? currentGameId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      playedGamesIds: playedGamesIds ?? this.playedGamesIds,
      gamesWon: gamesWon ?? this.gamesWon,
      photoURL: photoURL ?? this.photoURL,
      currentGameId:
          currentGameId != null ? currentGameId() : this.currentGameId,
    );
  }
}

extension UserExtensions on User {
  bool get isNone => this == User.none;

  bool get hasUsername => name.isNotBlank;
}
