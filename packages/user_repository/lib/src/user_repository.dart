import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared/shared.dart';

import 'models/user.dart';

class UserRepository {
  UserRepository() {
    _user = authUserChanges();
  }

  // ### Firebase instances:
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // ### User variables and getters:
  late final ValueStream<User> _user;
  User get user => _user.valueOrNull ?? User.none;
  Stream<User> get watchUser => _user.asBroadcastStream();

  // ### Methods:
  Future<User> getOpeningUser() {
    return watchUser.first.catchError((Object _) => User.none);
  }

  Future<void> signIn(String name) async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user!;

      final user = User(id: firebaseUser.uid, name: name);
      _updateUserData(user);
    } on FirebaseAuthException {
      throw AppFailure.fromSignIn();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception {
      throw AppFailure.fromSignOut();
    }
  }

  ValueStream<User> authUserChanges() {
    return _firebaseAuth
        .authStateChanges()
        .onErrorResumeWith((_, __) => null)
        .switchMap<User>(
          (firebaseUser) async* {
            if (firebaseUser == null) {
              yield User.none;
              return;
            }

            yield* _firebaseFirestore
                .userDoc(firebaseUser.uid)
                .snapshots()
                .map((snapshot) {
              if (snapshot.exists) {
                return User.fromJson(snapshot.data()!);
              }
              return User.none;
            });
          },
        )
        .handleError((Object _) => throw AppFailure.fromAuth())
        .shareValue();
  }

  Future<void> setCurrentGameId({required String currentGameId}) {
    return _firebaseFirestore
        .userDoc(user.id)
        .update({'currentGameId': currentGameId});
  }

  Future<void> _updateUserData(User user) async {
    return _firebaseFirestore
        .userDoc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }
}
