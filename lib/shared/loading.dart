
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  static const Color primaryBlue = Color(0xFF2457C5);
  static const Color darkBlue = Color(0xFF173A78);
  static const Color backgroundBlue = Color(0xFFF3F7FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App icon
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: primaryBlue,
                size: 38,
              ),
            ),

            const SizedBox(height: 32),

            // Modern animated spinner
            const SpinKitThreeBounce(
              color: primaryBlue,
              size: 24,
            ),

            const SizedBox(height: 24),

            const Text(
              'UNIMAS Events',
              style: TextStyle(
                color: darkBlue,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Getting things ready...',
              style: TextStyle(
                color: Colors.blueGrey.shade400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
