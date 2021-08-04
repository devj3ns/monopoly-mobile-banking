import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    this.currentGameId,
  });

  /// The users auth id.
  final String id;

  /// The users name.
  final String name;

  /// The id of the game the user is currently playing.
  final String? currentGameId;

  @override
  List<Object?> get props => [id, name, currentGameId];

  static User fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;

    return User(
      id: snap.id,
      name: data['name'] as String,
      currentGameId: data['currentGameId'] as String?,
    );
  }

  Map<String, Object?> toDocument() {
    return {
      'name': name,
      'currentGameId': currentGameId,
    };
  }
}
