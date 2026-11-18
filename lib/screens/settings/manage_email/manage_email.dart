import 'package:material_ui/material_ui.dart';

class ManageEmail extends StatelessWidget {
  const ManageEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Email')),
      body: const Center(
        child: Text('Email management options will be displayed here.'),
      ),
    );
  }
}
