//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_tracking_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

class AccountDeletionHelper {
  static Future<void> confirmDeleteAccount(BuildContext context) async {
    // 1. Ask for initial confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          size: 40,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. '
          'Your profile, saved data, and history will be permanently deleted.\n\n'
          'Note: Deleting your account does not cancel active App Store or Google Play subscriptions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 2. Attempt deletion with loading overlay
      await _runWithLoading(context, () => _deleteUserDataAndAuth(user));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (!context.mounted) return;

        // 3. Prompt for re-authentication if session is too old
        final reauthenticated = await _reauthenticateUser(context, user);
        if (!reauthenticated || !context.mounted) return;

        try {
          // 4. Retry deletion after successful re-authentication
          await _runWithLoading(context, () => _deleteUserDataAndAuth(user));
        } catch (retryError) {
          if (context.mounted) _showError(context, retryError);
          return;
        }
      } else {
        if (context.mounted) _showError(context, e);
        return;
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
      return;
    }

    // 5. Redirect to login screen and clear navigation history
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  /// Wraps an async task in a non-dismissible loading spinner
  static Future<void> _runWithLoading(
    BuildContext context,
    Future<void> Function() task,
  ) async {

    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await task();
    } finally {
      if (navigator.mounted) {
        navigator.pop();
      }
    }
  }

  /// Deletes Firestore user document first, then deletes Firebase Auth user
  static Future<void> _deleteUserDataAndAuth(User user) async {
    final uid = user.uid;

    // Delete from byteChew/{uid} (matches DatabaseService) BEFORE deleting Auth
    await DatabaseService(uid: uid).deleteUserData();

    // Optional: delete extra user-owned collections/subcollections or Storage files here

    // Delete the Firebase Auth account
    await user.delete();
  }

  /// Handles re-authentication when Firebase throws 'requires-recent-login'
  static Future<bool> _reauthenticateUser(
    BuildContext context,
    User user,
  ) async {
    final providerId = user.providerData.firstOrNull?.providerId;

    if (providerId == 'password' && user.email != null) {
      final password = await _showPasswordPrompt(context);
      if (password == null || password.isEmpty || !context.mounted) return false;

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await _runWithLoading(
        context,
        () => user.reauthenticateWithCredential(cred),
      );
      return true;
    }

    if (context.mounted) {
      _showError(
        context,
        'For security, please log out and log back in before deleting your account.',
      );
    }
    return false;
  }

  /// Dialog to collect password for email/password accounts
  static Future<String?> _showPasswordPrompt(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify Your Identity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your password to confirm account deletion.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  static void _showError(BuildContext context, Object error) {
    final message = error is FirebaseAuthException
        ? (error.message ?? error.code)
        : error.toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not delete account: $message'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
