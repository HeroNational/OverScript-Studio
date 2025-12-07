import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../../../data/models/playback_state.dart';
import '../../../../data/models/settings_model.dart';
import '../../../providers/playback_provider.dart';
import '../../../providers/settings_provider.dart';
import 'dart:convert';

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
      ref
          .read(playbackProvider.notifier)
          .setScrollController(_scrollController);
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
    final shouldMirror = settings.mirrorMode;

    final mirroredContent = Transform.scale(
      scaleX: shouldMirror ? -1.0 : 1.0,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, backgroundColor.withOpacity(0.92)],
        ),
      ),
      child: mirroredContent,
    );
  }

  Widget _buildContent(PlaybackState playbackState, SettingsModel settings) {
    if (playbackState.contentType == PlaybackContentType.pdf) {
      return _buildPdfContent(playbackState);
    }
    return _buildTextContent(playbackState, settings);
  }

  Widget _buildTextContent(
    PlaybackState playbackState,
    SettingsModel settings,
  ) {
    if (playbackState.richContentJson != null) {
      try {
        final document = quill.Document.fromJson(
          jsonDecode(playbackState.richContentJson!),
        );
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        return quill.QuillEditor(
          controller: controller,
          focusNode: FocusNode(),
          scrollController: _scrollController,
          config: quill.QuillEditorConfig(
            scrollable: true,
            autoFocus: false,
            expands: false,
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 64),
            showCursor: false,
            enableInteractiveSelection: false,
            customStyles: _quillStyles(settings),
          ),
        );
      } catch (_) {
        // Fallback plain text si parsing échoue
      }
    }

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
            fontFamily: settings.fontFamily == 'System'
                ? null
                : settings.fontFamily,
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

  quill.DefaultStyles _quillStyles(SettingsModel settings) {
    final base = quill.DefaultStyles.getInstance(context);
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      color: _parseColor(settings.textColor),
      height: 1.5,
      fontFamily: settings.fontFamily == 'System' ? null : settings.fontFamily,
    );

    return quill.DefaultStyles(
      h1: base.h1?.copyWith(
        style: textStyle.copyWith(fontSize: settings.fontSize * 1.6),
      ),
      h2: base.h2?.copyWith(
        style: textStyle.copyWith(fontSize: settings.fontSize * 1.4),
      ),
      h3: base.h3?.copyWith(
        style: textStyle.copyWith(fontSize: settings.fontSize * 1.2),
      ),
      h4: base.h4,
      h5: base.h5,
      h6: base.h6,
      paragraph: base.paragraph?.copyWith(style: textStyle),
      lineHeightNormal: base.lineHeightNormal,
      lineHeightTight: base.lineHeightTight,
      lineHeightOneAndHalf: base.lineHeightOneAndHalf,
      lineHeightDouble: base.lineHeightDouble,
      bold: base.bold?.copyWith(fontSize: textStyle.fontSize),
      italic: base.italic?.copyWith(fontSize: textStyle.fontSize),
      underline: base.underline?.copyWith(fontSize: textStyle.fontSize),
      strikeThrough: base.strikeThrough?.copyWith(fontSize: textStyle.fontSize),
      inlineCode: base.inlineCode,
      link: base.link,
      color: base.color,
      placeHolder: base.placeHolder?.copyWith(
        style: textStyle.copyWith(color: Colors.white54),
      ),
      lists: base.lists,
      quote: base.quote,
      code: base.code,
      indent: base.indent,
      align: base.align,
      leading: base.leading,
      sizeSmall: textStyle.copyWith(fontSize: settings.fontSize * 0.85),
      sizeLarge: base.sizeLarge,
      sizeHuge: base.sizeHuge,
      palette: base.palette,
    );
  }

  Widget _buildPdfContent(PlaybackState playbackState) {
    if (playbackState.isLoadingPdf) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
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

    final settings = ref.watch(settingsProvider);
    final pdfBackgroundColor = _parseColor(settings.backgroundColor);
    final pageColor = Color.lerp(pdfBackgroundColor, Colors.white, 0.12)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    return Container(
      color: pdfBackgroundColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 24,
          vertical: isMobile ? 16 : 24,
        ),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: pageColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(
              pages[index],
              fit: BoxFit.fitWidth,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
          );
        },
      ),
    );
  }
}
