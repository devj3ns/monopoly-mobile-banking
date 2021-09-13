import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fleasy/fleasy.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

import 'models/user.dart';

enum SignInResult {
  none,
  success,
  noConnection,
  failure,
}

enum ChooseUsernameResult {
  none,
  success,
  usernameAlreadyTaken,
  noConnection,
  failure
}

class UserRepository {
  UserRepository() {
    _user = _authUserChanges();
  }

  // ### Firebase instances: ###
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;
  static final _googleSignIn = GoogleSignIn.standard();

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

  /// Sets the username in the database.
  ///
  /// If the username is already taken [ChooseUsernameResult.usernameAlreadyTaken] is returned.
  Future<ChooseUsernameResult> chooseUsername(String username) async {
    try {
      // Create ref to usernames doc (usernames are case insensitive!)
      final usernamesDoc = usernamesCollection.doc(username.toLowerCase());

      // Check if username is already taken or not:
      final usernameIsTaken = (await usernamesDoc.get()).exists;

      // Return if it is already taken:
      if (usernameIsTaken) return ChooseUsernameResult.usernameAlreadyTaken;

      // Update username in the database:
      final updatedUser = _user.value.copyWith(name: username);
      await _updateUserData(updatedUser);

      // Create a document in the usernames collection:
      await usernamesDoc.set(<String, dynamic>{'userId': updatedUser.id});

      return ChooseUsernameResult.success;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
          return ChooseUsernameResult.noConnection;
        default:
          log('Unknown FirebaseException exception in chooseUsername(): $e');
          return ChooseUsernameResult.failure;
      }
    } catch (e) {
      log('Unknown exception in chooseUsername(): $e');

      return ChooseUsernameResult.failure;
    }
  }

  /// Signs in with Google.
  Future<SignInResult> signInWithGoogle() async {
    try {
      late UserCredential userCredential;
      if (DeviceType.isWeb) {
        await _firebaseAuth.signInWithRedirect(GoogleAuthProvider());

        userCredential = await _firebaseAuth.getRedirectResult();
      } else {
        // Trigger the authentication flow
        final googleSignInAccount = await _googleSignIn.signIn();

        if (googleSignInAccount == null) return SignInResult.none;

        // Obtain the auth details from the request
        final googleSignInAuth = await googleSignInAccount.authentication;

        // Create a new credential
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuth.accessToken,
          idToken: googleSignInAuth.idToken,
        );

        // Sign in with credential
        userCredential =
            await _firebaseAuth.signInWithCredential(oauthCredential);
      }

      // Get firebase auth user
      final firebaseUser = userCredential.user!;

      // Check if its the first time the user signs in with google
      final firstLogin = !(await userDocument(firebaseUser.uid).get()).exists;

      if (firstLogin) {
        // Create user with empty username in database when its the first login_screen
        // The username gets set later!
        final user = User(id: firebaseUser.uid, name: '', wins: 0);

        await _updateUserData(user);
      }

      return SignInResult.success;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
        case 'unavailable':
          return SignInResult.noConnection;
        default:
          log('Unknown FirebaseException exception in signInWithGoogle(): $e');
          return SignInResult.failure;
      }
    } on PlatformException catch (e) {
      switch (e.code) {
        case 'network_error':
          return SignInResult.noConnection;
        default:
          log('Unknown PlatformException exception in signInWithGoogle(): $e');
          return SignInResult.failure;
      }
    } catch (e) {
      log('Unknown exception in signInWithGoogle(): $e');

      return SignInResult.failure;
    }
  }

  /// Signs in anonymously.
  Future<SignInResult> signInAnonymously() async {
    try {
      // Create user in firebase auth:
      final userCredential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = userCredential.user!;

      // Create user with empty username in database when its the first login_screen
      // The username gets set later!
      final user = User(id: firebaseUser.uid, name: '', wins: 0);
      await _updateUserData(user);

      return SignInResult.success;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
        case 'unavailable':
          return SignInResult.noConnection;
        default:
          log('Unknown FirebaseException exception in signInAnonymously(): $e');
          return SignInResult.failure;
      }
    } catch (e) {
      log('Unknown exception in signInAnonymously(): $e');

      return SignInResult.failure;
    }
  }

  /// Signs out the user which updates [_authUserChanges].
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
    ]);
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
    return _updateUserData(user.copyWith(currentGameId: () => currentGameId));
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
