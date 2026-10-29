
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:event_tracking_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Convert Firebase User to your existing app user stream format.
  dynamic _userFromFirebaseUser(User? user) {
    return user;
  }

  // Determine role from university email domain.
  String? _determineUserRole(String? email) {
    if (email == null) return null;

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.endsWith('@siswa.unimas.my')) {
      return 'student';
    }

    if (normalizedEmail.endsWith('@unimas.my')) {
      return 'staff';
    }

    return null;
  }

  // Create a profile only if the user does not already have one.
  Future<void> _ensureUserProfile(
    User user, {
    String? publicName,
  }) async {
    final email = user.email;
    if (email == null || email.isEmpty) {
    throw Exception('No email was returned by the provider.');
  }

    final db = DatabaseService(uid: user.uid);
    final existingProfile = await db.getUserData();

    // Do not overwrite an existing profile.
    if (existingProfile != null) {
      // Keep the existing role and profile.
      return;
    }

    final role = _determineUserRole(email);

    if (role != null) {
      await db.createUserData(
        role,
        user.displayName ?? publicName ?? '',
        email,
      );
      return;
    }

    // Google accounts outside the university domains are public users.
    // Reject unknown Microsoft accounts rather than treating them as staff.
    final isMicrosoft = user.providerData.any(
      (provider) => provider.providerId == 'microsoft.com',
    );

    if (isMicrosoft) {
      throw Exception('This Microsoft account is not a recognized UNIMAS account.');
    }

    await db.updateUserData(
      'public',
      user.displayName ?? publicName ?? '',
    );
  }

  // Register with email and password (public users).
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String inputName,
  ) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      // Reserve university accounts for university sign-in.
      if (_determineUserRole(normalizedEmail) != null) {
        throw Exception(
          'Use Microsoft sign-in for your UNIMAS account.',
        );
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = result.user;
      if (user == null) return null;

      await user.updateDisplayName(inputName);
      await DatabaseService(uid: user.uid).updateUserData(
        'public',
        inputName,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Registration error: $e');
      return null;
    }
  }

  // Sign in with email and password (public users).
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Email login error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Email login error: $e');
      return null;
    }
  }

  // Sign in with Microsoft (UNIMAS students and staff).
  Future<User?> signInWithMicrosoft() async {

     final provider = MicrosoftAuthProvider()
    ..addScope('email')
    ..addScope('openid')
    ..addScope('profile')
    ..setCustomParameters({
      'prompt': 'select_account',
      // 'tenant': '<unimas-tenant-id>',  // uncomment to restrict to UNIMAS
    });

  final result = kIsWeb
      ? await _auth.signInWithPopup(provider)
      : await _auth.signInWithProvider(provider);

  final user = result.user;
  if (user == null) throw Exception('No user returned.');

  // Fall back to the email in providerData if user.email is null.
  final email = user.email ??
      user.providerData
          .map((p) => p.email)
          .firstWhere((e) => e != null && e.isNotEmpty, orElse: () => null);
  debugPrint('MS email resolved: $email');

  if (_determineUserRole(email) == null) {
    await _auth.signOut();
    throw Exception('Please use an authorized UNIMAS account.');
  }

  await _ensureUserProfile(user);
  return user;
}

  // Sign in with Google (public users).
  // i got this from https://www.geeksforgeeks.org/firebase/flutter-google-sign-in-ui-and-authentication/
  Future<User?> signInWithGoogle() async {
     try {
            
            // Trigger the Google Sign-In flow.
            final googleUser = await _googleSignIn.authenticate();
            
            // Retrieve the authentication details from the Google account.
            final googleAuth = googleUser.authentication;
            
            // Create a new credential using the Google authentication details.
            final credential = GoogleAuthProvider.credential(
                    idToken: googleAuth.idToken,
            );
            
            // Sign in to Firebase with the Google credential.
            final userCredential = await _auth.signInWithCredential(credential);
            
            // Return the authenticated user.
            return userCredential.user; 
        } catch (e) {
            
            // Print the error and return null if an exception occurs.
            print("Sign-in error: $e");
            return null;
        }
    }

  // Sign out.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Auth state stream.
  Stream<User?> get user => _auth.authStateChanges();
}