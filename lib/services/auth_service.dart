import 'package:firebase_auth/firebase_auth.dart';

enum AuthProvider { anonymous, google, facebook, apple, email, phone, unknown }

class AuthService {
  // initializing an instance of user
  static final AuthService instance = AuthService._internal();
  static final FirebaseAuth auth = FirebaseAuth.instance;

  AuthService._internal();

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  // the auth providers
  AuthProvider get authProvider {
    final user = currentUser;

    if (user == null) return AuthProvider.unknown;
    if (user.isAnonymous) return AuthProvider.anonymous;

    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : '';

    switch (providerId) {
      case 'google.com':
        return AuthProvider.google;
      case 'facebook.com':
        return AuthProvider.facebook;
      case 'apple.com':
        return AuthProvider.apple;
      case 'password':
        return AuthProvider.email;
      case 'phone':
        return AuthProvider.phone;
      default:
        return AuthProvider.unknown;
    }
  }

  // if the user is logged in
  bool get isLoggedIn =>
      authProvider != AuthProvider.unknown &&
      authProvider != AuthProvider.anonymous;

  // guest log in
  static Future<UserCredential> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  // user sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }
}
