import 'package:material_ui/material_ui.dart';

class ManageEvent extends StatelessWidget {
  const ManageEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: const Center(
        child: Text('Event management interface will be displayed here.'),
      ),
    );
  }
}