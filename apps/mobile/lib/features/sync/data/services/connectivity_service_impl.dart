import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/services/connectivity_service.dart';

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _lastStatus = false;

  ConnectivityServiceImpl(this._connectivity) {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final isReachable = await hasInternetAccess();
      if (_lastStatus != isReachable) {
        _lastStatus = isReachable;
        _controller.add(isReachable);
      }
    });
  }

  @override
  Stream<bool> get isConnectedStream => _controller.stream;

  @override
  Future<bool> hasInternetAccess() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Check actual internet reachability to avoid Captive Portal / Local Network drops
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }
}
