import 'dart:async';

import 'package:flutter/services.dart';

class Notifier {
  static const MethodChannel _channel =
      const MethodChannel('notifier');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
