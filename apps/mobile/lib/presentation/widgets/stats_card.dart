import 'package:flutter/material.dart';
import '../../core/presentation/layout/responsive.dart';
import 'app_card.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const StatsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: EdgeInsets.symmetric(
          vertical: AppResponsive.isCompact(context) ? 12 : 16,
          horizontal: AppResponsive.isCompact(context) ? 8 : 12,
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: AppResponsive.text(context, 24),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
