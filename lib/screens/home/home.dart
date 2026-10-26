
import 'package:event_tracking_app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_tracking_app/screens/settings/settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final TextEditingController _searchController =
      TextEditingController();

  String _userRole = 'guest';

  Future<String> _getUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return 'guest';
    }

    final document = await FirebaseFirestore.instance
        .collection('byteChew')
        .doc(currentUser.uid)
        .get();

    if (!document.exists) {
      return 'guest';
    }

    final data = document.data();
    return data?['role'] as String? ?? 'guest';
  }

  @override
  void initState() {
    super.initState();
    _getUserRole().then((role) {
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    });
  }

  final List<String> _categories = [
    'All events',
    'Academic',
    'Sports',
    'Social',
    'Workshop',
  ];

  String _selectedCategory = 'All events';

  bool get _canManageEvents =>
      _userRole == 'organizer' || _userRole == 'admin';

  bool get _isAdmin => _userRole == 'admin';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPlaceholder(String feature) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be implemented later.'),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 42,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'UNIMAS Events',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover what is happening',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              _buildDrawerItem(
                icon: Icons.home_outlined,
                title: 'Home',
                onTap: () => Navigator.pop(context),
              ),
              _buildDrawerItem(
                icon: Icons.person_outline,
                title: 'My Profile',
                onTap: () => _showPlaceholder('My Profile'),
              ),
              _buildDrawerItem(
                icon: Icons.event_available_outlined,
                title: 'Joined Events',
                onTap: () => _showPlaceholder('Joined Events'),
              ),
              _buildDrawerItem(
                icon: Icons.bookmark_border,
                title: 'Saved Events',
                onTap: () => _showPlaceholder('Saved Events'),
              ),

              const Divider(),

              if (_canManageEvents) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'EVENT MANAGEMENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.add_circle_outline,
                  title: 'Create Event',
                  onTap: () => _showPlaceholder('Create Event'),
                ),
                _buildDrawerItem(
                  icon: Icons.event_note_outlined,
                  title: 'Manage My Events',
                  onTap: () => _showPlaceholder('Manage My Events'),
                ),
              ],

              if (_isAdmin) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'ADMINISTRATION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.fact_check_outlined,
                  title: 'Review Event Submissions',
                  onTap: () =>
                      _showPlaceholder('Review Event Submissions'),
                ),
                _buildDrawerItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'User Management',
                  onTap: () => _showPlaceholder('User Management'),
                ),
              ],

              const Divider(),

              _buildDrawerItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserSettings(),
                    ),
                  );
                },
              ),

              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Sign Out',
                onTap: () async {
                  Navigator.pop(context);
                  await _auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'UNIMAS Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 44,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Notifications',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You will see event reminders, updates, '
                            'and other notifications here.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Discover Events',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find activities, programmes, and events around you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Upcoming Events',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showPlaceholder('Event filters');
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 36,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 58,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Events will appear here',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published events will be displayed here. '
                    'You will be able to search, filter, and '
                    'explore events once event data is connected.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
