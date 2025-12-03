import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../data/services/video_library_service.dart';
import '../../l10n/app_localizations.dart';
import '../screens/settings/settings_screen.dart';

class AppMenuSheet extends ConsumerStatefulWidget {
  const AppMenuSheet({super.key});

  @override
  ConsumerState<AppMenuSheet> createState() => _AppMenuSheetState();
}

class _AppMenuSheetState extends ConsumerState<AppMenuSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final VideoLibraryService _videoService = VideoLibraryService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0f172a),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n?.appTitle ?? 'OverScript Studio'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n?.settings ?? 'Settings'),
              Tab(text: 'Infos'),
              Tab(text: 'Vidéos'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const SettingsScreen(),
            _buildSystemInfo(context),
            _buildVideoLibrary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _infoTile('OS', Platform.operatingSystem),
          _infoTile('Version OS', Platform.operatingSystemVersion),
          _infoTile('Resolution', '${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}'),
          _infoTile('Dart', Platform.version),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildVideoLibrary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder(
      future: _videoService.listVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n?.error ?? 'Erreur',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        final files = snapshot.data ?? [];
        if (files.isEmpty) {
          return Center(
            child: Text(
              'Aucune vidéo trouvée',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final name = file.uri.pathSegments.last;
            return ListTile(
              leading: const Icon(Icons.video_library, color: Colors.white70),
              title: Text(name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(file.statSync().modified.toIso8601String(),
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () => _openPlayer(context, file.path),
            );
          },
        );
      },
    );
  }

  Future<void> _openPlayer(BuildContext context, String path) async {
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    controller.play();
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0f172a),
          content: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.pause();
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            )
          ],
        );
      },
    ).then((_) => controller.dispose());
  }
}
