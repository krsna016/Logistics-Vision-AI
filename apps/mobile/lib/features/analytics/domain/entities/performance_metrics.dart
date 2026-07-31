class AIPerformanceMetrics {
  final double averageConfidence;
  final double inferenceTimeMs;
  final double fps;
  final int manualCorrections;
  final int rejectedDetections;
  final double retakeRate;
  final double detectionSuccessRate;
  final String activeModelVersion;

  const AIPerformanceMetrics({
    this.averageConfidence = 0.0,
    this.inferenceTimeMs = 0.0,
    this.fps = 0.0,
    this.manualCorrections = 0,
    this.rejectedDetections = 0,
    this.retakeRate = 0.0,
    this.detectionSuccessRate = 0.0,
    this.activeModelVersion = 'N/A',
  });
}

class LoadingPerformanceMetrics {
  final double cartonsLoadedPerHour;
  final double averageLayersPerTruck;
  final Duration averageTruckCompletionTime;
  final Duration averageWagonCompletionTime;
  final int averageCartonsPerLayer;

  // For time-series trend chart
  final List<double> hourlyCartonTrend;

  const LoadingPerformanceMetrics({
    this.cartonsLoadedPerHour = 0.0,
    this.averageLayersPerTruck = 0.0,
    this.averageTruckCompletionTime = Duration.zero,
    this.averageWagonCompletionTime = Duration.zero,
    this.averageCartonsPerLayer = 0,
    this.hourlyCartonTrend = const [],
  });
}

class DatasetHealthMetrics {
  final int imagesCaptured;
  final int approvedImages;
  final int rejectedImages;
  final int exportedImages;
  final int pendingReview;
  final double storageUsedMB;
  final double blurPercentage;
  final double lightingIssues;

  // For time-series trend
  final List<double> dailyCaptureTrend;

  const DatasetHealthMetrics({
    this.imagesCaptured = 0,
    this.approvedImages = 0,
    this.rejectedImages = 0,
    this.exportedImages = 0,
    this.pendingReview = 0,
    this.storageUsedMB = 0.0,
    this.blurPercentage = 0.0,
    this.lightingIssues = 0.0,
    this.dailyCaptureTrend = const [],
  });
}

class ProductivityMetrics {
  final double averageOperatorPerformance; // 0.0 - 1.0 score
  final double truckThroughput; // Trucks per day
  final double averageLayersPerHour;
  final double averageCartonsPerHour;
  final Duration averageSessionDuration;

  const ProductivityMetrics({
    this.averageOperatorPerformance = 0.0,
    this.truckThroughput = 0.0,
    this.averageLayersPerHour = 0.0,
    this.averageCartonsPerHour = 0.0,
    this.averageSessionDuration = Duration.zero,
  });
}
