
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:event_tracking_app/services/theme_service.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Preferences',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // APPEARANCE: Light, Dark, or System default.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.palette_outlined),
                    title: Text('Appearance'),
                    subtitle: Text('Choose how the app looks'),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_suggest_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeService.themeMode},
                    onSelectionChanged: (selection) {
                      themeService.setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: 'Manage your name and profile details',
                  onTap: () => _showComingSoon(
                    context,
                    'Personal Information',
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: 'Manage your sign-in email',
                  onTap: () => _showComingSoon(
                    context,
                    'Email Address',
                  ),
                ),

                // TODO: Add account linking and provider management
                // for Microsoft, Google, and email/password accounts.
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Security & Permissions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Password & Sign-in',
                  subtitle: 'Manage password and authentication methods',
                  onTap: () => _showComingSoon(
                    context,
                    'Password & Sign-in',
                  ),
                ),
                const Divider(height: 1),
                _SettingsTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Permissions',
                  subtitle: 'View your account access and role',
                  onTap: () => _showPermissions(context),
                ),

                // IMPORTANT:
                // Users must not be allowed to grant themselves
                // organizer/admin privileges from this screen.
                // Role changes must be controlled by trusted logic.
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              subtitle: 'Manage reminders and event updates',
              onTap: () => _showComingSoon(
                context,
                'Notification Preferences',
              ),
            ),
          ),

          // TODO: Add notification preferences:
          // - Event reminders
          // - Event cancellations and schedule changes
          // - Event approval/rejection updates
          // - Push notification preferences

          const SizedBox(height: 24),

          Text(
            'Danger Zone',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: _SettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              iconColor: colors.error,
              titleColor: colors.error,
              onTap: () => _confirmDeleteAccount(context),
            ),
          ),

          // TODO: Implement account deletion through a trusted backend.
          // The backend must handle Firebase Authentication, the
          // user's Firestore profile, and related application data.
          // Require recent authentication where applicable.

          const SizedBox(height: 32),

          Center(
            child: Text(
              'UNIMAS Events',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'More settings and features can be added here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),

          // TODO: Add future settings here.
          // Examples: language, accessibility, privacy policy,
          // terms of service, blocked users, and data export.
        ],
      ),
    );
  }

  static void _showComingSoon(
    BuildContext context,
    String feature,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be implemented later.'),
      ),
    );
  }

  static Future<void> _showPermissions(
    BuildContext context,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showComingSoon(context, 'Account permissions');
      return;
    }

    try {
      final document = await FirebaseFirestore.instance
          .collection('byteChew')
          .doc(user.uid)
          .get();

      if (!context.mounted) return;

      final role = document.data()?['role'] as String? ?? 'unassigned';

      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Your Permissions'),
          content: Text(
            'Current role: $role\n\n'
            'Your available features depend on the permissions '
            'assigned to your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load account permissions.'),
        ),
      );
    }
  }

  static Future<void> _confirmDeleteAccount(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          size: 40,
        ),
        title: const Text('Delete Account?'),
        content: const Text(
          'Account deletion is not connected yet. '
          'When implemented, this action will permanently remove '
          'your account and may remove associated data. '
          'You may need to sign in again to verify your identity.\n\n'
          'Do you want to continue to the account deletion setup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Intentionally does not delete anything yet.
    // Connect this action to a secure account-deletion workflow.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account deletion is not implemented yet.',
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
