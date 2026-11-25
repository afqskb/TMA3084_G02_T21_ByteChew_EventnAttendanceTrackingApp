import 'package:material_ui/material_ui.dart';

class ManageUser extends StatelessWidget {
  const ManageUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: const Center(
        child: Text('User management interface will be displayed here.'),
      ),
    );
  }
}