import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/app/app.dart';
import 'package:kikikaikai/core/media/media_playback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MediaPlayback.init();
  runApp(const ProviderScope(child: KikikaikaiApp()));
}
