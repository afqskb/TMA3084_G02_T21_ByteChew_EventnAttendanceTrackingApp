import 'package:material_ui/material_ui.dart';

class EventSaved extends StatelessWidget {
  const EventSaved({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Events')),
      body: const Center(
        child: Text('List of saved events will be displayed here.'),
      ),
    );
  }
}
