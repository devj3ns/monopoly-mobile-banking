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

enum SetUsernameResult {
  none,
  success,
  usernameAlreadyTaken,
  noConnection,
  failure
}

class UserRepository {
  UserRepository({required this.useFirebaseEmulator}) {
    _user = _authUserChanges();

    if (useFirebaseEmulator) {
      _firebaseFirestore.useFirestoreEmulator('localhost', 8080);
      _firebaseAuth.useAuthEmulator('localhost', 9099);
    }
  }

  final bool useFirebaseEmulator;

  // ### Firebase instances: ###
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;
  static final _googleSignIn = GoogleSignIn.standard();

  // ### Firestore collections: ###
  final _usernamesCollection = _firebaseFirestore.collection('usernames');
  final _usersCollection =
      _firebaseFirestore.collection('users').withConverter<User>(
            fromFirestore: (snap, _) =>
                User.fromJson(snap.data()!, snapshotId: snap.id),
            toFirestore: (model, _) => model.toJson(),
          );

  // ### User variables and getters: ###
  /// A stream of the currently authenticated user that provides synchronous access to the last emitted user object.
  late final ValueStream<User> _user;

  /// The currently authenticated user and his data or [User.none] if unauthenticated.
  User get user => _user.valueOrNull ?? User.none;

  /// A stream of the currently authenticated user and his data or [User.none] if unauthenticated.
  Stream<User> get watchUser => _user.asBroadcastStream();

  /// Weather the currently logged in user is signed in anonymous.
  bool get currentUserIsAnonymous {
    assert(_firebaseAuth.currentUser != null);

    return _firebaseAuth.currentUser!.isAnonymous;
  }

  // ### Methods: ###
  /// Returns the first element of the [watchUser] stream.
  Future<User> getOpeningUser() {
    return watchUser.first.catchError((Object _) => User.none);
  }

  /// Sets the username in the database.
  ///
  /// If the username is already taken [SetUsernameResult.usernameAlreadyTaken] is returned.
  Future<SetUsernameResult> setUsername(String username) async {
    try {
      // Create ref to usernames doc (usernames are case insensitive!)
      final usernamesDoc = _usernamesCollection.doc(username.toLowerCase());

      // Check if username is already taken or not:
      final usernameIsTaken = (await usernamesDoc.get()).exists;

      // Return if it is already taken:
      if (usernameIsTaken) return SetUsernameResult.usernameAlreadyTaken;

      // Delete old username doc if the username should be changed
      if (user.hasUsername) {
        final oldUsernameDoc =
            _usernamesCollection.doc(_user.value.name.toLowerCase());
        await oldUsernameDoc.delete();
      }

      // Create a doc with the (new) username in the usernames collection:
      await usernamesDoc.set(<String, dynamic>{'userId': _user.value.id});

      // Update username in the user data doc:
      final updatedUser = _user.value.copyWith(name: username);
      await _setUserData(updatedUser);

      return SetUsernameResult.success;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
          return SetUsernameResult.noConnection;
        default:
          log('Unknown FirebaseException exception in setUsername(): $e');
          return SetUsernameResult.failure;
      }
    } catch (e) {
      log('Unknown exception in setUsername(): $e');

      return SetUsernameResult.failure;
    }
  }

  /// Signs in with Google.
  ///
  /// If it's the first login, the user is also created in the database.
  /// For its username the displayName of the google account is used. If that is already forgiven, he has to choose another name.
  Future<SignInResult> signInWithGoogle() async {
    try {
      late UserCredential userCredential;
      if (DeviceType.isWeb) {
        // Use signInWithPopup instead of signInWithRedirect, because it's easier to implement
        userCredential =
            await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
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
      final firstLogin =
          !(await _usersCollection.doc(firebaseUser.uid).get()).exists;

      if (firstLogin) {
        // Check if google username is already taken or not:
        final googleUsernameIsTaken = (await _usernamesCollection
                .doc(firebaseUser.displayName!.toLowerCase())
                .get())
            .exists;

        if (googleUsernameIsTaken) {
          // Create user with empty username in database.
          // When the username is blank the 'choose username screen' is shown automatically.
          final user = User.none.copyWith(id: firebaseUser.uid);

          await _setUserData(user);
        } else {
          // Create user with username in the users collection:
          final user = User.none.copyWith(
            id: firebaseUser.uid,
            name: firebaseUser.displayName!,
            photoURL: firebaseUser.photoURL,
          );

          await _setUserData(user);

          // Create a document in the usernames collection:
          await _usernamesCollection
              .doc(firebaseUser.displayName!.toLowerCase())
              .set(<String, dynamic>{'userId': firebaseUser.uid});
        }
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
      final user = User.none.copyWith(id: firebaseUser.uid);
      await _setUserData(user);

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

  /// Deletes the users account and all its data in the database.
  Future<void> _deleteUser(User user) async {
    // It's important that it is done in this order:
    await _usernamesCollection.doc(user.name.toLowerCase()).delete();
    await _usersCollection.doc(user.id).delete();
    await _firebaseAuth.currentUser!.delete();
  }

  /// Signs out the user which updates [_authUserChanges].
  ///
  /// If the users singed in anonymous his account gets deleted.
  Future<void> signOut() async {
    if (_firebaseAuth.currentUser!.isAnonymous) {
      await _deleteUser(user);
    }

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

        yield* _usersCollection.doc(firebaseUser.uid).snapshots().map(
              (snapshot) => snapshot.exists ? snapshot.data()! : User.none,
            );
      },
    ).shareValue();
  }

  /// Sets the currentGameId property of the user to the given id.
  Future<void> setCurrentGameId(String? currentGameId) {
    return _setUserData(user.copyWith(currentGameId: () => currentGameId));
  }

  /// Increments the gamesWon property of the user.
  Future<void> incrementGamesWon() {
    return _setUserData(user.copyWith(gamesWon: user.gamesWon + 1));
  }

  /// Adds the given game id to the playedGamesIds property of the user.
  Future<void> addGameId(String gameId) async {
    final playedGamesIds = Set<String>.from(user.playedGamesIds)..add(gameId);
    final updatedUser = user.copyWith(playedGamesIds: playedGamesIds);

    return await _setUserData(updatedUser);
  }

  /// Sets the users data to the given use data.
  Future<void> _setUserData(User user) async {
    return await _usersCollection
        .doc(user.id)
        .set(user, SetOptions(merge: true));
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
