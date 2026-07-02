import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/app.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/providers/database_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaPlayback.init();
  final database = await bootstrapAppDatabase();
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const KikikaikaiApp(),
    ),
  );
}
