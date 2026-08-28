import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Tracks whether the device has a route to the network.
///
/// This answers "is there an interface up", not "is the API reachable" — a
/// captive portal still reads as online here. Treat it as a hint for the UI,
/// not as a substitute for handling a failed request.
class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<ConnectivityService> init() async {
    isOnline.value = _isOnline(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) => isOnline.value = _isOnline(results),
    );
    return this;
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.isNotEmpty &&
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
