import 'package:connectivity_plus/connectivity_plus.dart';

class connectivityController {
  static Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    print(connectivityResult[0]);
    bool isConnected = connectivityResult[0] == ConnectivityResult.mobile || connectivityResult[0] == ConnectivityResult.wifi;
    return isConnected;
  }
}