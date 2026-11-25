// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_tracking_app/screens/settings/account_delete/account_delete.dart';
import 'package:event_tracking_app/screens/settings/personal_information/personal_information.dart';
import 'package:event_tracking_app/screens/settings/manage_email/manage_email.dart';
import 'package:event_tracking_app/screens/settings/link_account/link_account.dart';
import 'package:event_tracking_app/screens/settings/manage_credential/manage_credential.dart';
import 'package:event_tracking_app/screens/settings/view_permission/view_permission.dart';
import 'package:event_tracking_app/screens/settings/notification_preference/notification_preference.dart';
import 'package:event_tracking_app/services/theme_service.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInformation(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: 'Manage your sign-in email',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageEmail(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.link_outlined,
                  title: 'Linked Accounts',
                  subtitle: 'Manage connected sign-in providers',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LinkAccount(),
                      ),
                    );
                  },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageCredential(),
                      ),
                    );
                  },
                ),

                const Divider(height: 1),

                _SettingsTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Permissions',
                  subtitle: 'View your account access and role',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewPermission(),
                      ),
                    );
                  },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPreference(),
                  ),
                );
              },
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
               onTap: () => AccountDeletionHelper.confirmDeleteAccount(context),
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
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
