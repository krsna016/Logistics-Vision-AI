enum Environment {
  development,
  staging,
  production;

  static Environment get current {
    const configured = String.fromEnvironment('ENV');
    const isRelease = bool.fromEnvironment('dart.vm.product');
    final env = configured.isEmpty
        ? (isRelease
            ? Environment.production.name
            : Environment.development.name)
        : configured;
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  /// Credential-free local Administrator access is available automatically in
  /// non-production builds. Release builds must opt in explicitly at compile
  /// time with `--dart-define=ENABLE_LOCAL_ADMIN_ENTRY=true`.
  static bool get enableLocalAdministratorEntry =>
      current != Environment.production ||
      const bool.fromEnvironment('ENABLE_LOCAL_ADMIN_ENTRY');

  String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
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
  bool get enableDetailedTelemetry => this == Environment.staging;
}
