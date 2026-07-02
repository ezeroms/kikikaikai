import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/providers/database_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// VM テスト向けに in-memory DB を初期化した [ProviderContainer] を返す。
Future<ProviderContainer> createTestProviderContainer() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final database = await bootstrapAppDatabase(inMemory: true);
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
    ],
  );
}
