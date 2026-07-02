import 'package:flutter/foundation.dart';

/// 再生・ミニプレイヤー周りのデバッグログ（debug ビルドのみ）
abstract final class PlaybackDebugLog {
  static void log(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[PlaybackDebug:$tag] $message');
    }
  }
}
