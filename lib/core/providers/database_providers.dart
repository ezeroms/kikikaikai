import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/data/local/app_database.dart';

/// `main()` で初期化して [ProviderScope.overrides] 経由で注入する。
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'AppDatabase is not initialized. Call bootstrapAppDatabase() in main().',
  ),
);

Future<AppDatabase> bootstrapAppDatabase({bool inMemory = false}) {
  return AppDatabase.open(inMemory: inMemory);
}
