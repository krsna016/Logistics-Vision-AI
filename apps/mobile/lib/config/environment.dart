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
        return 'https://logistics-vision-ai.onrender.com/api'; // Switched to cloud backend for testing
      case Environment.staging:
        return 'https://logistics-vision-ai.onrender.com/api';
      case Environment.production:
        return 'https://logistics-vision-ai.onrender.com/api';
    }
  }

  bool get enableLogging => this != Environment.production;
  bool get enableDetailedTelemetry => this != Environment.development;
}
