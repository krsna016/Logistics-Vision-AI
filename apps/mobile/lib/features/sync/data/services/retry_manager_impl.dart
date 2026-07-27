import 'dart:math';
import '../../domain/services/retry_manager.dart';

class RetryManagerImpl implements RetryManager {
  final int maxRetries;
  final List<int> backoffMinutes = const [1, 2, 4, 8, 16];

  RetryManagerImpl({this.maxRetries = 5});

  @override
  bool shouldRetry(int currentRetryCount) {
    return currentRetryCount < maxRetries;
  }

  @override
  Duration calculateNextDelay(int currentRetryCount) {
    if (currentRetryCount >= backoffMinutes.length) {
      return Duration(minutes: backoffMinutes.last);
    }
    return Duration(minutes: backoffMinutes[max(0, currentRetryCount)]);
  }
}
