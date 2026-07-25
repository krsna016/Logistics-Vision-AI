enum Environment {
  development,
  staging,
  production;

  static Environment get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  String get apiBaseUrl {
    switch (this) {
      case Environment.development:
        return 'http://localhost:8000/api/v1';
      case Environment.staging:
        return 'https://staging.logisticsvision.ai/api/v1';
      case Environment.production:
        return 'https://api.logisticsvision.ai/api/v1';
    }
  }

  bool get enableLogging => this != Environment.production;
  bool get enableDetailedTelemetry => this != Environment.development;
}
