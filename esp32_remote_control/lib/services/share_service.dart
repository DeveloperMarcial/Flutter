import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('com.meshadapter.esp32_remote_control/share');

  static Future<bool> shareFile({
    required String filePath,
    String? title,
    String? subject,
    String? text,
  }) async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final res = await _channel.invokeMethod<bool>('shareFile', {
        'filePath': filePath,
        'title': title,
        'subject': subject,
        'text': text,
      });
      return res ?? false;
    } catch (e, st) {
      debugPrint('[ShareService] Error sharing file: $e\n$st');
      return false;
    }
  }
}
