import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtil {
  PlatformUtil._();

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get isWeb => kIsWeb;

  static bool get isDesktop => !kIsWeb && Platform.isWindows;
}
