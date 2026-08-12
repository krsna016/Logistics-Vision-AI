import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/digital_register.dart';

class RegisterReconciliationCard extends StatelessWidget {
  final DigitalRegister register;

  const RegisterReconciliationCard({super.key, required this.register});

  @override
  Widget build(BuildContext context) {
    final hasManifest = register.hasManifest;
    final reconciled = register.isReconciled;
    final stateColor = hasManifest
        ? (reconciled ? AppTheme.successColor : AppTheme.errorColor)
        : AppTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stateColor.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                !hasManifest
                    ? Icons.info_outline
                    : (reconciled
                        ? Icons.verified_outlined
                        : Icons.error_outline),
                color: stateColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  !hasManifest
                      ? 'ITEM MANIFEST NOT PROVIDED'
                      : (reconciled
                          ? 'REGISTER RECONCILED'
                          : 'RECONCILIATION REQUIRED'),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _metric('Manifest',
                  hasManifest ? '${register.manifestCartons}' : '--'),
              _metric('Loaded', '${register.totalCartons}'),
              _metric('Remaining',
                  hasManifest ? '${register.remainingCartons}' : '--'),
            ],
          ),
          if (register.itemBalances.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.dividerColor),
            const SizedBox(height: 8),
            ...register.itemBalances.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.itemName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: _smallValue('Total', item.manifest)),
                      Expanded(child: _smallValue('Loaded', item.loaded)),
                      Expanded(
                          child: _smallValue('Left', item.remaining,
                              alert: item.remaining < 0)),
                    ],
                  ),
                )),
          ],
          if (!reconciled) ...[
            const SizedBox(height: 12),
            ...register.reconciliationIssues.map((issue) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('- $issue',
                      style: const TextStyle(
                          color: AppTheme.errorColor, fontSize: 12)),
                )),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _smallValue(String label, int value, {bool alert = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: alert ? AppTheme.errorColor : Colors.white)),
          Text(label.toUpperCase(),
              style:
                  const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
        ],
      );
}
