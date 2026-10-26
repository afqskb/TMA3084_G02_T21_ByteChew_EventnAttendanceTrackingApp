
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:event_tracking_app/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to your existing app user stream format.
  // Keep this if your app already uses this mapping.
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
    User? user;

    try {
      final provider = MicrosoftAuthProvider();

      final result = kIsWeb
          ? await _auth.signInWithPopup(provider)
          : await _auth.signInWithProvider(provider);

      user = result.user;
      if (user == null) return null;

      final role = _determineUserRole(user.email);

      if (role == null) {
        await _auth.signOut();
        throw Exception('Please use an authorized UNIMAS account.');
      }

      await _ensureUserProfile(user);
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Microsoft login error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Microsoft login error: $e');
      return null;
    }
  }

  // Sign in with Google (public users).
  Future<User?> signInWithGoogle() async {
     try {
    debugPrint('GOOGLE 1: Initializing sign-in');

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();

    debugPrint('GOOGLE 2: Selecting account');

    final googleUser = await googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    debugPrint('GOOGLE 3: Getting Firebase credential');

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    debugPrint('GOOGLE 4: Signing in to Firebase');

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    if (user == null) {
      debugPrint('GOOGLE ERROR: Firebase returned no user');
      return null;
    }

    debugPrint('GOOGLE 5: Checking user profile');

    final role = _determineUserRole(user.email);

    if (role != null) {
      await _auth.signOut();
      debugPrint('GOOGLE ERROR: University account must use Microsoft');
      return null;
    }

    await _ensureUserProfile(user);

    debugPrint('GOOGLE 6: Sign-in completed successfully');
    return user;
  } on FirebaseAuthException catch (e) {
    debugPrint('GOOGLE FIREBASE ERROR: ${e.code} - ${e.message}');
    return null;
  } on FirebaseException catch (e) {
    debugPrint('GOOGLE FIRESTORE ERROR: ${e.code} - ${e.message}');
    return null;
  } catch (e, stackTrace) {
    debugPrint('GOOGLE OTHER ERROR: $e');
    debugPrint('$stackTrace');
    return null;
  }
}

  // Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auth state stream.
  Stream<User?> get user => _auth.authStateChanges();
}
