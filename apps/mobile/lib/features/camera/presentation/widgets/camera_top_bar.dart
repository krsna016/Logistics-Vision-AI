import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CameraTopBar extends StatelessWidget {
  final String wagonNumber;
  final String truckNumber;
  final int layerNumber;
  final bool isOnline;
  final int totalCartons;

  const CameraTopBar({
    super.key,
    required this.wagonNumber,
    required this.truckNumber,
    required this.layerNumber,
    this.isOnline = false,
    this.totalCartons = 0,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SafeArea(
      child: Container(
        color: const Color(0xCC000000),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Left Side: Logo & Title
            Row(
              children: [
                Image.asset('assets/images/logo.png', width: 20, height: 20, fit: BoxFit.contain),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Vinayak SmartLoad',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Powered by Vinayak Logistics',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            
            // Middle Area
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('WAGON', style: TextStyle(color: Colors.grey, fontSize: 9)),
                      Text(wagonNumber, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('TRUCK', style: TextStyle(color: Colors.grey, fontSize: 9)),
                      Text(truckNumber, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('LAYER', style: TextStyle(color: Colors.grey, fontSize: 9)),
                      Text('$layerNumber', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Right Side
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.battery_full, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  timeString,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOnline ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
