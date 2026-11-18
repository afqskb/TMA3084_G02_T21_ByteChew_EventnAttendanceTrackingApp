import 'package:material_ui/material_ui.dart';

class ManageCredential extends StatelessWidget {
  const ManageCredential({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Credential')),
      body: const Center(
        child: Text('Credential management options will be displayed here.'),
      ),
    );
  }
}
