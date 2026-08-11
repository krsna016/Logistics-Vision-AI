import 'package:flutter/material.dart';

class ScannerStartingView extends StatelessWidget {
  const ScannerStartingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      key: ValueKey('camera-loading'),
      color: Colors.black,
      child: Center(
        child: SizedBox.square(
          dimension: 34,
          child: CircularProgressIndicator(
            strokeWidth: 2.6,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}
