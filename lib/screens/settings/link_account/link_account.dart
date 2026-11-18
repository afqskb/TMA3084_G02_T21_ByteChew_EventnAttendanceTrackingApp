import 'package:material_ui/material_ui.dart';

class LinkAccount extends StatelessWidget {
  const LinkAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Account')),
      body: const Center(
        child: Text('Account linking options will be displayed here.'),
      ),
    );
  }
}
