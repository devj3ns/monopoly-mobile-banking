import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum AuthResult { none, success, failure }

class AuthRepository {
  // #### Firebase instances:
  static final _firebaseAuth = FirebaseAuth.instance;

  // #### Public methods:
  /// Returns the user (if authenticated) or null (if unauthenticated).
  Stream<User?> get streamAuthUserChanges => _firebaseAuth.authStateChanges();

  /// Asynchronously creates and becomes a user.
  ///
  /// If successful, the users id is returned.
  Future<String?> signIn() async {
    try {
      final userCredentials = await _firebaseAuth.signInAnonymously();
      final uid = userCredentials.user!.uid;

      return uid;
    } catch (error) {
      debugPrint('FAILED TO SIGN IN.');
      debugPrint(error.toString());

      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async => await _firebaseAuth.signOut();
}
