import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/models.dart';

//todo: add more auth results
enum AuthResult {
  none,
  success,
  failure,
}

class AuthRepository {
  // #### Firebase instances:
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _firebaseFirestore = FirebaseFirestore.instance;

  // #### Collection references:
  static CollectionReference<User> get _usersCollection =>
      _firebaseFirestore.collection('users').withConverter<User>(
            fromFirestore: (snap, _) => User.fromSnapshot(snap),
            toFirestore: (model, _) => model.toDocument(),
          );

  // #### Private methods:
  /// Gets the user from the database by the given id.
  Future<User?> _getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();

      return doc.data()!;
    } catch (e) {
      await signOut();
    }
  }

  // #### Public methods:
  /// Returns the user (if authenticated) or null (if unauthenticated).
  Stream<User?> get streamUser {
    return _firebaseAuth.authStateChanges().asyncMap(
      (firebaseUser) async {
        return firebaseUser != null
            ? await _getUserById(firebaseUser.uid)
            : null;
      },
    );
  }

  /// Returns the current user (if authenticated) or null (if unauthenticated)
  Future<User?> get user => streamUser.first;

  /// Asynchronously creates and becomes a user.
  ///
  /// If successful, it updates any authStateChanges, idTokenChanges or userChanges stream listeners.
  Future<AuthResult> signIn({
    required String firstName,
  }) async {
    try {
      final userCredentials = await _firebaseAuth.signInAnonymously();
      final uid = userCredentials.user!.uid;

      await _usersCollection.doc(uid).set(User(id: uid, firstName: firstName));

      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        default:
          return AuthResult.failure;
      }
    }
  }

  /// Signs out the current user.
  ///
  /// If successful, it updates any authStateChanges, idTokenChanges or userChanges stream listeners.
  Future<void> signOut() async => await _firebaseAuth.signOut();
}
