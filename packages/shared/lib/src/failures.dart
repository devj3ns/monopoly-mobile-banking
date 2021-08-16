class AppFailure implements Exception {
  const AppFailure._();

  factory AppFailure.fromAuth() => const AuthFailure();
  factory AppFailure.fromSignOut() => const SignOutFailure();
  factory AppFailure.fromSignIn() => const SignInFailure();

  static const none = AppNoFailure();

  bool get requiresReauthentication {
    return this is AuthFailure;
  }
}

class AppNoFailure extends AppFailure {
  const AppNoFailure() : super._();
}

class AuthFailure extends AppFailure {
  const AuthFailure() : super._();
}

class SignOutFailure extends AppFailure {
  const SignOutFailure() : super._();
}

class SignInFailure extends AppFailure {
  const SignInFailure() : super._();
}
