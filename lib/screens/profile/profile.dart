import 'package:material_ui/material_ui.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('User profile information will be displayed here.'),
      ),
    );
  }
}
