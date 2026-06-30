import 'package:audio_service/audio_service.dart';
import 'package:kikikaikai/core/media/kikikaikai_media_handler.dart';
import 'package:kikikaikai/core/models/content.dart';

class MediaPlayback {
  MediaPlayback._();

  static bool _initialized = false;
  static KikikaikaiMediaHandler? _handler;

  static Future<void> init() async {
    if (_initialized) return;
    _handler = await AudioService.init(
      builder: () => KikikaikaiMediaHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'tokyo.kikikaikai.media',
        androidNotificationChannelName: '奇奇怪怪',
        androidNotificationChannelDescription: 'ラジオ・テレビの再生',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        preloadArtwork: true,
      ),
    );
    _initialized = true;
  }

  static KikikaikaiMediaHandler? get handler => _handler;

  static Future<void> playContent(
    Content content, {
    Duration? previewLimit,
  }) async {
    await init();
    final h = handler;
    if (h == null) return;
    await h.playContent(content, previewLimit: previewLimit);
  }

  static Future<void> stop() async {
    await handler?.stop();
  }
}
