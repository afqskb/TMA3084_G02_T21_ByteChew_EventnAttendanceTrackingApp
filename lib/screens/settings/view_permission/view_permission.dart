import 'package:material_ui/material_ui.dart';

class ViewPermission extends StatelessWidget {
  const ViewPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Permission')),
      body: const Center(
        child: Text('Permission details will be displayed here.'),
      ),
    );
  }
}
