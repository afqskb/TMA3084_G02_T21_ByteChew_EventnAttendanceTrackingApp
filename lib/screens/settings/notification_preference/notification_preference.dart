import 'package:material_ui/material_ui.dart';

class NotificationPreference extends StatelessWidget {
  const NotificationPreference({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preference')),
      body: const Center(
        child: Text('Notification preference settings will be displayed here.'),
      ),
    );
  }
}
