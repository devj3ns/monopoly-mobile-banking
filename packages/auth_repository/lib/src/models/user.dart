import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.firstName,
  });

  final String id;
  final String firstName;

  @override
  List<Object> get props => [
        id,
        firstName,
      ];

  static User fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;

    return User(
      id: snap.id,
      firstName: data['firstName'] as String,
    );
  }

  Map<String, Object> toDocument() {
    return {
      'firstName': firstName,
    };
  }
}
