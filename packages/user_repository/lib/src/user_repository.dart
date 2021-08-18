import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'package:shared/shared.dart';

import 'models/user.dart';

class UserRepository {
  UserRepository() {
    _user = _authUserChanges();
  }

  // ### Firebase instances: ###
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // ### User variables and getters: ###
  /// A stream of the currently authenticated user that provides synchronous access to the last emitted user object.
  late final ValueStream<User> _user;

  /// The currently authenticated user and his data or [User.none] if unauthenticated.
  User get user => _user.valueOrNull ?? User.none;

  /// A stream of the currently authenticated user and his data or [User.none] if unauthenticated.
  Stream<User> get watchUser => _user.asBroadcastStream();

  // ### Methods: ###
  /// Returns the first element of the [watchUser] stream.
  Future<User> getOpeningUser() {
    return watchUser.first.catchError((Object _) => User.none);
  }

  /// Creates a new account for the user and signs him in which updates [_authUserChanges].
  Future<void> signIn(String name) async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user!;

      final user = User(id: firebaseUser.uid, name: name, wins: 0);
      await _updateUserData(user);
    } on FirebaseAuthException {
      throw AppFailure.fromSignIn();
    }
  }

  /// Signs out the user which updates [_authUserChanges].
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception {
      throw AppFailure.fromSignOut();
    }
  }

  /// Stream which returns the authenticated user and his data or [User.none] if unauthenticated.
  ///
  /// Combines firebase auth's authStateChanges and the
  /// firebase firestore's snapshots of the user document.
  ValueStream<User> _authUserChanges() {
    return _firebaseAuth
        .authStateChanges()
        .onErrorResumeWith((_, __) => null)
        .switchMap<User>(
          (firebaseUser) async* {
            if (firebaseUser == null) {
              yield User.none;

              return;
            }

            yield* _firebaseFirestore.userDoc(firebaseUser.uid).snapshots().map(
                  (snapshot) => snapshot.exists
                      ? User.fromJson(snapshot.data()!, snapshotId: snapshot.id)
                      : User.none,
                );
          },
        )
        .handleError((Object _) => throw AppFailure.fromAuth())
        .shareValue();
  }

  Future<void> setCurrentGameId(String? currentGameId) {
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
