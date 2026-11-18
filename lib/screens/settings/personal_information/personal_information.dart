import 'package:material_ui/material_ui.dart';

class PersonalInformation extends StatelessWidget {
  const PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Information')),
      body: const Center(
        child: Text('User personal information will be displayed here.'),
      ),
    );
  }
}
