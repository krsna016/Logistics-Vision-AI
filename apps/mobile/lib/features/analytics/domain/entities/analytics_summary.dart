class AnalyticsSummary {
  final int totalWagons;
  final int totalTrucks;
  final int totalLayers;
  final int totalCartons;
  final double averageConfidence;
  final Duration averageLoadingTime;

  const AnalyticsSummary({
    this.totalWagons = 0,
    this.totalTrucks = 0,
    this.totalLayers = 0,
    this.totalCartons = 0,
    this.averageConfidence = 0.0,
    this.averageLoadingTime = Duration.zero,
  });
}
