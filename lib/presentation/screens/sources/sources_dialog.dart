import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:prompteur/l10n/app_localizations.dart';
import 'package:prompteur/core/utils/subtitle_parser.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class SourceData {
  final String? text;
  final String? pdfPath;
  final String? quillJson;

  const SourceData({this.text, this.pdfPath, this.quillJson});

  bool get isPdf => pdfPath != null;
  bool get isRichText => quillJson != null;
}

class SourcesDialog extends StatelessWidget {
  final Function(SourceData) onSourceSelected;
  final String? initialText;
  final String? initialQuillJson;

  const SourcesDialog({
    super.key,
    required this.onSourceSelected,
    this.initialText,
    this.initialQuillJson,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            padding: EdgeInsets.all(screenWidth > 500 ? 32 : 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.circle_plus,
                      color: Colors.white,
                      size: screenWidth > 500 ? 28 : 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.addSource,
                        style: TextStyle(
                          fontSize: screenWidth > 500 ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tooltip(
                      message: l10n.close,
                      child: IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                        iconSize: screenWidth > 500 ? 24 : 20,
                        constraints: BoxConstraints(
                          minWidth: screenWidth > 500 ? 48 : 36,
                          minHeight: screenWidth > 500 ? 48 : 36,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeSubtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                _SourceOption(
                  icon: LucideIcons.file_text,
                  title: l10n.loadTextFile,
                  subtitle: l10n.loadTextFileDescription,
                  gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  onTap: () async {
                    print('[FilePicker] Opening text file picker...');
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['txt', 'vtt', 'srt'],
                        allowMultiple: false,
                        withData: false,
                        withReadStream: false,
                      );

                      print('[FilePicker] Result: ${result != null ? "File selected" : "No file selected"}');

                      if (result != null && result.files.single.path != null) {
                        final path = result.files.single.path!;
                        print('[FilePicker] Selected file: $path');
                        final file = File(path);
                        String content = await file.readAsString();
                        final ext = (result.files.single.extension ?? path.split('.').last).toLowerCase();

                        if (ext == 'srt' || ext == 'vtt') {
                          content = SubtitleParser.cleanSubtitleContent(content);
                        }

                        Navigator.of(context, rootNavigator: true).pop(SourceData(text: content));
                      }
                    } catch (e) {
                      print('[FilePicker] Error: $e');
                    }
                  },
                ),
                const SizedBox(height: 16),
                _SourceOption(
                  icon: LucideIcons.file,
                  title: l10n.loadPdfFile,
                  subtitle: l10n.loadPdfFileDescription,
                  gradientColors: const [Color(0xFFEC4899), Color(0xFFF59E0B)],
                  onTap: () async {
                    print('[FilePicker] Opening PDF file picker...');
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                        allowMultiple: false,
                        withData: false,
                        withReadStream: false,
                      );

                      print('[FilePicker] PDF Result: ${result != null ? "File selected" : "No file selected"}');

                      if (result != null && result.files.single.path != null) {
                        final path = result.files.single.path!;
                        print('[FilePicker] Selected PDF: $path');
                        Navigator.of(context, rootNavigator: true).pop(SourceData(pdfPath: path));
                      }
                    } catch (e) {
                      print('[FilePicker] PDF Error: $e');
                    }
                  },
                ),
                const SizedBox(height: 16),
                _SourceOption(
                  icon: LucideIcons.pen_line,
                  title: l10n.textEditor,
                  subtitle: l10n.richTextMode,
                  gradientColors: const [Color(0xFF10B981), Color(0xFF06B6D4)],
                  onTap: () {
                    _showRichEditor(context).then((source) {
                      if (source != null) {
                        Navigator.of(context, rootNavigator: true).pop(source);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTextEditor(BuildContext context, Function(SourceData) onSourceSelected) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final dialogWidth = screenWidth > 800 ? 700.0 : screenWidth * 0.9;
        final dialogHeight = screenHeight > 600 ? 500.0 : screenHeight * 0.75;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 22,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(dialogWidth > 600 ? 32 : 20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.pen_line,
                        color: Colors.white,
                        size: dialogWidth > 600 ? 28 : 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Éditer le texte',
                          style: TextStyle(
                            fontSize: dialogWidth > 600 ? 24 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!.close,
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                          iconSize: dialogWidth > 600 ? 24 : 20,
                          constraints: BoxConstraints(
                            minWidth: dialogWidth > 600 ? 48 : 36,
                            minHeight: dialogWidth > 600 ? 48 : 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: textController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.pasteYourText,
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Tooltip(
                        message: AppLocalizations.of(context)!.cancel,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!.save,
                        child: ElevatedButton(
                          onPressed: () {
                            onSourceSelected(SourceData(text: textController.text));
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: dialogWidth > 600 ? 32 : 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Future<SourceData?> _showRichEditor(BuildContext context) {
    quill.QuillController controller;

    try {
      controller = initialQuillJson != null
          ? quill.QuillController(
              document: quill.Document.fromJson(jsonDecode(initialQuillJson!)),
              selection: const TextSelection.collapsed(offset: 0),
            )
          : quill.QuillController.basic();

      if (initialText != null && initialQuillJson == null && initialText!.isNotEmpty) {
        final replaceLen = controller.document.length - 1;
        if (replaceLen >= 0) {
          controller.document.replace(0, replaceLen, initialText!);
        }
      }
    } catch (e) {
      print('[ERROR] Failed to initialize Quill controller: $e');
      controller = quill.QuillController.basic();
    }

    return showDialog<SourceData>(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final dialogWidth = screenWidth > 900 ? 780.0 : screenWidth * 0.9;
        final dialogHeight = screenHeight > 700 ? 540.0 : screenHeight * 0.8;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: EdgeInsets.all(dialogWidth > 600 ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.pen_line,
                        color: Colors.white,
                        size: dialogWidth > 600 ? 28 : 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.richTextMode,
                          style: TextStyle(
                            fontSize: dialogWidth > 600 ? 24 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!.close,
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                          iconSize: dialogWidth > 600 ? 24 : 20,
                          constraints: BoxConstraints(
                            minWidth: dialogWidth > 600 ? 48 : 36,
                            minHeight: dialogWidth > 600 ? 48 : 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Simple toolbar row without QuillSimpleToolbar to avoid bugs
                          Builder(
                            builder: (context) {
                              final screenWidth = MediaQuery.of(context).size.width;
                              final isMobile = screenWidth < 500;
                              final toolbarHeight = isMobile ? 40.0 : 48.0;
                              final iconSize = isMobile ? 16.0 : 18.0;

                              return Container(
                                height: toolbarHeight,
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: Icon(LucideIcons.undo_2, color: Colors.white70, size: iconSize),
                                        onPressed: () => controller.undo(),
                                        tooltip: 'Undo',
                                        iconSize: iconSize,
                                        constraints: BoxConstraints(
                                          minWidth: isMobile ? 32 : 40,
                                          minHeight: isMobile ? 32 : 40,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(LucideIcons.redo_2, color: Colors.white70, size: iconSize),
                                        onPressed: () => controller.redo(),
                                        tooltip: 'Redo',
                                        iconSize: iconSize,
                                        constraints: BoxConstraints(
                                          minWidth: isMobile ? 32 : 40,
                                          minHeight: isMobile ? 32 : 40,
                                        ),
                                      ),
                                      VerticalDivider(color: Colors.white10, width: isMobile ? 8 : 16),
                                      IconButton(
                                        icon: Icon(LucideIcons.bold, color: Colors.white70, size: iconSize),
                                        onPressed: () {
                                          controller.formatSelection(quill.Attribute.bold);
                                        },
                                        tooltip: 'Bold',
                                        iconSize: iconSize,
                                        constraints: BoxConstraints(
                                          minWidth: isMobile ? 32 : 40,
                                          minHeight: isMobile ? 32 : 40,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(LucideIcons.italic, color: Colors.white70, size: iconSize),
                                        onPressed: () {
                                          controller.formatSelection(quill.Attribute.italic);
                                        },
                                        tooltip: 'Italic',
                                        iconSize: iconSize,
                                        constraints: BoxConstraints(
                                          minWidth: isMobile ? 32 : 40,
                                          minHeight: isMobile ? 32 : 40,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(LucideIcons.underline, color: Colors.white70, size: iconSize),
                                        onPressed: () {
                                          controller.formatSelection(quill.Attribute.underline);
                                        },
                                        tooltip: 'Underline',
                                        iconSize: iconSize,
                                        constraints: BoxConstraints(
                                          minWidth: isMobile ? 32 : 40,
                                          minHeight: isMobile ? 32 : 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: quill.QuillEditor(
                                controller: controller,
                                focusNode: FocusNode(),
                                scrollController: ScrollController(),
                                config: const quill.QuillEditorConfig(
                                  scrollable: true,
                                  autoFocus: true,
                                  expands: true,
                                  padding: EdgeInsets.all(12),
                                  showCursor: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Tooltip(
                        message: AppLocalizations.of(context)!.cancel,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: AppLocalizations.of(context)!.save,
                        child: ElevatedButton(
                          onPressed: () {
                            final delta = controller.document.toDelta().toJson();
                            final plain = controller.document.toPlainText();
                            Navigator.of(context, rootNavigator: true).pop(
                              SourceData(quillJson: jsonEncode(delta), text: plain),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: dialogWidth > 600 ? 32 : 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}

class _SourceOption extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_SourceOption> createState() => _SourceOptionState();
}

class _SourceOptionState extends State<_SourceOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isCompactLayout = isMobile;

    return Tooltip(
      message: widget.subtitle,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: _isHovered ? 1.02 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: isCompactLayout
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors
                      .map((c) => c.withOpacity(_isHovered ? 0.35 : 0.22))
                      .toList(),
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.gradientColors[0].withOpacity(_isHovered ? 0.55 : 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors[0].withOpacity(_isHovered ? 0.28 : 0.18),
                    blurRadius: _isHovered ? 18 : 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isCompactLayout
                  ? _buildCompactLayout()
                  : _buildDesktopLayout(),
            ),
          ),
        ),
      ),
    );
  }

  /// Layout pour desktop (icon à gauche, texte au centre, chevron à droite)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Icon(
          LucideIcons.chevron_right,
          color: Colors.white.withOpacity(0.5),
          size: 20,
        ),
      ],
    );
  }

  /// Layout pour mobile (icon au centre, texte en bas)
  Widget _buildCompactLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
