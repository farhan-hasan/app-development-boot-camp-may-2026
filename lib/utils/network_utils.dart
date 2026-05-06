import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hisabi/config/theme.dart';

class NetworkException implements Exception {
  const NetworkException.offline()
      : isOffline = true,
        isTimeout = false;
  const NetworkException.timeout()
      : isOffline = false,
        isTimeout = true;

  final bool isOffline;
  final bool isTimeout;

  String get message => isOffline
      ? 'No internet connection. Please turn on Wi-Fi or mobile data.'
      : 'Connection is slow. Please check your internet and try again.';
}

Future<bool> isConnected() async {
  final results = await Connectivity().checkConnectivity();
  return results.any((r) => r != ConnectivityResult.none);
}

void showNetworkSnackBar(BuildContext context, dynamic error) {
  final msg = error is NetworkException
      ? error.message
      : 'Something went wrong. Please check your internet connection.';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: kDanger,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 4),
    ),
  );
}
