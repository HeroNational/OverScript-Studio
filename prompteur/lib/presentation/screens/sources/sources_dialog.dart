import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompteur/core/utils/subtitle_parser.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:prompteur/l10n/app_localizations.dart';
import 'dart:convert';

class SourceData {
  final String? text;
  final String? pdfPath;
  final String? quillJson;

  const SourceData({this.text, this.pdfPath, this.quillJson});

  bool get isPdf => pdfPath != null;
  bool get isRichText => quillJson != null;
}

class SourcesDialog extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 500,
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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.circle_plus,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.addSource,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: l10n.close,
                      child: IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
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
                  title: l10n.loadFile,
                  subtitle: l10n.loadFile,
                  gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['txt', 'vtt', 'srt'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final path = result.files.single.path!;
                      final file = File(path);
                      String content = await file.readAsString();
                      final ext = (result.files.single.extension ?? path.split('.').last).toLowerCase();

                      if (ext == 'srt' || ext == 'vtt') {
                        content = SubtitleParser.cleanSubtitleContent(content);
                      }

                      Navigator.of(context, rootNavigator: true).pop(SourceData(text: content));
                    }
                  },
                ),
                const SizedBox(height: 16),
                _SourceOption(
                  icon: LucideIcons.file,
                  title: l10n.loadFile,
                  subtitle: l10n.loadFile,
                  gradientColors: const [Color(0xFFEC4899), Color(0xFFF59E0B)],
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (result != null && result.files.single.path != null) {
                      Navigator.of(context, rootNavigator: true).pop(SourceData(pdfPath: result.files.single.path!));
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 700,
              height: 500,
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
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.pen_line, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.textEditor,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: AppLocalizations.of(context)!.close,
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                      const SizedBox(width: 16),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
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
      ),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 780,
              height: 540,
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.pen_line, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.richTextMode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Tooltip(
                        message: AppLocalizations.of(context)!.close,
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
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
                          quill.QuillSimpleToolbar(
                            controller: controller,
                            config: const quill.QuillSimpleToolbarConfig(
                              axis: Axis.horizontal,
                              multiRowsDisplay: true,
                              showAlignmentButtons: true,
                              showBackgroundColorButton: false,
                              showUndo: true,
                              showRedo: true,
                            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                      const SizedBox(width: 16),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
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
      ),
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
              padding: const EdgeInsets.all(20),
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
              child: Row(
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
