import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'models/user.dart';

enum SignInResult { none, success, usernameIsTaken, noConnection, failure }

class UserRepository {
  UserRepository() {
    _user = _authUserChanges();
  }

  // ### Firebase instances: ###
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // ### Firestore collections: ###
  final usernamesCollection = _firebaseFirestore.collection('usernames');
  final usersCollection = _firebaseFirestore.collection('users');
  DocumentReference<Map<String, dynamic>> userDocument(String userId) =>
      usersCollection.doc(userId);

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

  /// Creates a new account with the given username and signs in which updates [_authUserChanges].
  ///
  /// If the username is already taken [SignInResult.usernameIsTaken] is returned.
  Future<SignInResult> signIn(String username) async {
    try {
      // Create ref to usernames doc (usernames are case insensitive!)
      final usernamesDoc = usernamesCollection.doc(username.toLowerCase());

      // Check if username is already taken or not:
      final usernameIsTaken = (await usernamesDoc.get()).exists;

      // Return if it is already taken:
      if (usernameIsTaken) return SignInResult.usernameIsTaken;

      // Create user in firebase auth:
      final userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user!;

      // Create user in the database:
      final user = User(id: firebaseUser.uid, name: username, wins: 0);
      await _updateUserData(user);

      // Create a document in the usernames collection:
      await usernamesDoc.set(<String, dynamic>{'userId': firebaseUser.uid});

      return SignInResult.success;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
          return SignInResult.noConnection;
        default:
          log('Unknown FirebaseException exception in signIn(): $e');
          return SignInResult.failure;
      }
    } catch (e) {
      log('Unknown exception in signIn(): $e');

      return SignInResult.failure;
    }
  }

  /// Signs out the user which updates [_authUserChanges].
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
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

        yield* userDocument(firebaseUser.uid).snapshots().map(
              (snapshot) => snapshot.exists
                  ? User.fromJson(snapshot.data()!, snapshotId: snapshot.id)
                  : User.none,
            );
      },
    ).shareValue();
  }

  Future<void> setCurrentGameId(String? currentGameId) {
    return userDocument(user.id).update({'currentGameId': currentGameId});
  }

  Future<void> _updateUserData(User user) async {
    return userDocument(user.id).set(user.toJson(), SetOptions(merge: true));
  }
}

extension StreamExtensions<T> on Stream<T> {
  Stream<T> onErrorResumeWith(
    T Function(Object error, StackTrace stackTrace) valueOnError,
  ) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleError: (Object error, StackTrace stackTrace, EventSink<T> sink) {
          sink.add(valueOnError(error, stackTrace));
        },
      ),
    );
  }
}
