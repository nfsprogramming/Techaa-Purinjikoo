import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AppLogger {
  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode || AppConfig.current.enableDebugLogs) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void i(String message) {
    if (kDebugMode || AppConfig.current.enableDebugLogs) {
      debugPrint('[INFO] $message');
    }
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[WARN] $message');
    if (error != null) debugPrint('Details: $error');
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Details: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}
