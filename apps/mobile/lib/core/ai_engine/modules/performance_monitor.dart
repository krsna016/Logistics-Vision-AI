class PerformanceMetrics {
  final double fps;
  final double averageInferenceTime;
  final double preProcessingTime;
  final double postProcessingTime;
  final int totalDetections;

  const PerformanceMetrics({
    this.fps = 0.0,
    this.averageInferenceTime = 0.0,
    this.preProcessingTime = 0.0,
    this.postProcessingTime = 0.0,
    this.totalDetections = 0,
  });
}

class PerformanceMonitor {
  int _frameCount = 0;
  int _totalDetections = 0;
  DateTime _lastFpsTime = DateTime.now();
  double _currentFps = 0.0;

  final List<double> _inferenceHistory = [];
  final List<double> _preProcessingHistory = [];
  final List<double> _postProcessingHistory = [];

  void recordFrame(
      double preTime, double infTime, double postTime, int detCount) {
    _frameCount++;
    _totalDetections += detCount;
    _inferenceHistory.add(infTime);
    _preProcessingHistory.add(preTime);
    _postProcessingHistory.add(postTime);
    if (_inferenceHistory.length > 30) {
      _inferenceHistory.removeAt(0);
      _preProcessingHistory.removeAt(0);
      _postProcessingHistory.removeAt(0);
    }

    final now = DateTime.now();
    final diff = now.difference(_lastFpsTime).inMilliseconds;
    if (diff >= 1000) {
      _currentFps = (_frameCount / diff) * 1000;
      _frameCount = 0;
      _lastFpsTime = now;
    }
  }

  PerformanceMetrics getMetrics() {
    final avgInf = _inferenceHistory.isEmpty
        ? 0.0
        : _inferenceHistory.reduce((a, b) => a + b) / _inferenceHistory.length;
    final avgPre = _average(_preProcessingHistory);
    final avgPost = _average(_postProcessingHistory);

    return PerformanceMetrics(
      fps: _currentFps,
      averageInferenceTime: avgInf,
      preProcessingTime: avgPre,
      postProcessingTime: avgPost,
      totalDetections: _totalDetections,
    );
  }

  double _average(List<double> values) => values.isEmpty
      ? 0.0
      : values.reduce((first, second) => first + second) / values.length;
}
