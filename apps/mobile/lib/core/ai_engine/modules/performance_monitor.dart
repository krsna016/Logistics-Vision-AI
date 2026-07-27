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
  DateTime _lastFpsTime = DateTime.now();
  double _currentFps = 0.0;
  
  final List<double> _inferenceHistory = [];

  void recordFrame(double preTime, double infTime, double postTime, int detCount) {
    _frameCount++;
    _inferenceHistory.add(infTime);
    if (_inferenceHistory.length > 30) {
      _inferenceHistory.removeAt(0);
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

    return PerformanceMetrics(
      fps: _currentFps,
      averageInferenceTime: avgInf,
    );
  }
}
