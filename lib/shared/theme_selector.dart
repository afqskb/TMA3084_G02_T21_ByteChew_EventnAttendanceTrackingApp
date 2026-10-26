
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_tracking_app/services/theme_service.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return DropdownButtonFormField<ThemeMode>(
      value: themeService.themeMode,
      decoration: const InputDecoration(
        labelText: 'Appearance',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: ThemeMode.system,
          child: Text('System default'),
        ),
        DropdownMenuItem(
          value: ThemeMode.light,
          child: Text('Light mode'),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: Text('Dark mode'),
        ),
      ],
      onChanged: (mode) {
        if (mode != null) {
          themeService.setThemeMode(mode);
        }
      },
    );
  }
}
