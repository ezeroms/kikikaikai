import 'package:flutter/foundation.dart';

/// カテゴリタブ固定背景のレイアウト調査用ログ（debug ビルドのみ）
abstract final class CategoryTabBackgroundDebugLog {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[CategoryTabBg] $message');
    }
  }
}
