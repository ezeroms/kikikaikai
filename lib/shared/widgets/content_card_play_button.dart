import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kikikaikai/core/media/content_card_playback.dart';
import 'package:kikikaikai/core/media/media_playback.dart';
import 'package:kikikaikai/core/models/content.dart';
import 'package:kikikaikai/core/providers/providers.dart';
import 'package:kikikaikai/shared/widgets/circular_media_button.dart';

class ContentCardPlayButton extends ConsumerWidget {
  const ContentCardPlayButton({
    super.key,
    required this.content,
    this.compact = false,
    this.size = 56,
  });

  final Content content;
  final bool compact;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTier = ref.watch(userTierProvider);
    if (!ContentCardPlayback.showsCardPlayButton(content, userTier)) {
      return const SizedBox.shrink();
    }

    final savedProgress = ref
        .watch(contentEngagementProvider)
        .valueOrNull
        ?.playbackFor(content.id);

    void toggle() => ContentCardPlayback.toggle(
          context,
          content: content,
          tier: userTier,
          savedProgress: savedProgress,
        );

    final handler = MediaPlayback.handler;

    if (compact) {
      if (handler == null) {
        return CircularMediaButton.compact(onPressed: toggle);
      }
      return StreamBuilder<PlaybackState>(
        stream: handler.playbackState,
        builder: (context, snapshot) {
          final isCurrent = handler.currentContent?.id == content.id;
          final playing = isCurrent && (snapshot.data?.playing ?? false);
          return CircularMediaButton.compact(
            onPressed: toggle,
            playing: playing,
          );
        },
      );
    }

    return CircularMediaButton.overlay(
      onPressed: toggle,
      size: size,
    );
  }
}
