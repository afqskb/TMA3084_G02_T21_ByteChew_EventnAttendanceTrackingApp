import 'package:material_ui/material_ui.dart';

class CreateEvent extends StatelessWidget {
  const CreateEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: const Center(
        child: Text('Event creation interface will be displayed here.'),
      ),
    );
  }
}