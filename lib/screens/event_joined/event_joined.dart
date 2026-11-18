import 'package:material_ui/material_ui.dart';

class EventJoined extends StatelessWidget {
  const EventJoined({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Joined Events')),
      body: const Center(
        child: Text('List of joined events will be displayed here.'),
      ),
    );
  }
}
