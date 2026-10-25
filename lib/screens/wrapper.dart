import 'package:event_tracking_app/screens/authenticate/authenticate.dart';
import 'package:event_tracking_app/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:event_tracking_app/models/AppUser.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<AppUser?>(context);

    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }

    
  }
}