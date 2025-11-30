import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:prompteur/l10n/app_localizations.dart';
import '../../providers/playback_provider.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reset button
        IconButton(
          icon: const Icon(LucideIcons.skip_back),
          iconSize: 32,
          onPressed: () {
            ref.read(playbackProvider.notifier).reset();
          },
          tooltip: l10n?.reset ?? 'Réinitialiser',
        ),
        const SizedBox(width: 16),
        // Play/Pause button
        IconButton(
          icon: Icon(
            playbackState.isPlaying ? LucideIcons.pause : LucideIcons.play,
          ),
          iconSize: 48,
          onPressed: () {
            ref.read(playbackProvider.notifier).togglePlayPause();
          },
          tooltip: playbackState.isPlaying
              ? (l10n?.pause ?? 'Pause')
              : (l10n?.play ?? 'Lecture'),
        ),
      ],
    );
  }
}
