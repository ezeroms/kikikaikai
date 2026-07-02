import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 詳細画面でヘッダーが完全に隠れたときにミニプレイヤーを表示する。
final detailMiniPlayerVisibleProvider = StateProvider<bool>((ref) => false);

/// 現在表示中の詳細画面コンテンツ ID（ルーターパスが不安定な Shell 内 push 向け）
final detailScreenContentIdProvider = StateProvider<String?>((ref) => null);
