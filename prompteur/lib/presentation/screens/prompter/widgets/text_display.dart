import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/playback_state.dart';
import '../../../../data/models/settings_model.dart';
import '../../../providers/playback_provider.dart';
import '../../../providers/settings_provider.dart';

class TextDisplay extends ConsumerStatefulWidget {
  const TextDisplay({super.key});

  @override
  ConsumerState<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends ConsumerState<TextDisplay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playbackProvider.notifier).setScrollController(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);
    final settings = ref.watch(settingsProvider);
    final backgroundColor = _parseColor(settings.backgroundColor);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.92),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildContent(playbackState, settings),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 80,
            child: IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PlaybackState playbackState, SettingsModel settings) {
    if (playbackState.contentType == PlaybackContentType.pdf) {
      return _buildPdfContent(playbackState);
    }
    return _buildTextContent(playbackState, settings);
  }

  Widget _buildTextContent(PlaybackState playbackState, SettingsModel settings) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: settings.fontSize,
            color: _parseColor(settings.textColor),
            height: 1.5,
            fontFamily: settings.fontFamily == 'System' ? null : settings.fontFamily,
          ),
          child: Text(
            playbackState.currentText ??
                'Aucun texte chargé.\n\nCollez votre texte ou importez un fichier.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPdfContent(PlaybackState playbackState) {
    if (playbackState.isLoadingPdf) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      );
    }

    if (playbackState.pdfError != null) {
      return Center(
        child: Text(
          'Impossible de charger le PDF.\n${playbackState.pdfError}',
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    final pages = playbackState.pdfPages;
    if (pages == null || pages.isEmpty) {
      return const Center(
        child: Text(
          'PDF vide ou non supporté.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            pages[index],
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
