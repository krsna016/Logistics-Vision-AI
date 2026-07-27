abstract class RetryManager {
  /// Calculates if an operation should be retried based on its current retryCount.
  bool shouldRetry(int currentRetryCount);

  /// Calculates the delay duration for the next retry attempt using exponential backoff.
  Duration calculateNextDelay(int currentRetryCount);
}
