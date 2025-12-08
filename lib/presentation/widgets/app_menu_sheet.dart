import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/video_library_service.dart';
import '../../data/services/storage_service.dart';
import '../../l10n/app_localizations.dart';
import '../screens/settings/settings_screen.dart';
import '../providers/settings_provider.dart';

class AppMenuSheet extends ConsumerStatefulWidget {
  const AppMenuSheet({super.key});

  @override
  ConsumerState<AppMenuSheet> createState() => _AppMenuSheetState();
}

class _AppMenuSheetState extends ConsumerState<AppMenuSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final VideoLibraryService _videoService = VideoLibraryService();
  final StorageService _storage = StorageService();
  late Future<List<FileSystemEntity>> _videosFuture;
  late Future<Map<String, dynamic>> _infoFuture;

  @override
  void initState() {
    super.initState();
    debugPrint('[UI] AppMenuSheet opened');
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      debugPrint('[UI] Menu tab changed to index: ${_tabController.index}');
    });
    _videosFuture = _videoService.listVideos();
    _infoFuture = _gatherSystemInfo();
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
              Tab(text: l10n?.infoOverviewTitle ?? 'Infos'),
              Tab(text: l10n?.videosTab ?? 'Vidéos'),
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
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _infoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final recordingsPath = data['recordingsPath'] as String?;
        final localeCode = (data['locale'] ?? 'fr').toString();
        final localeLabel = localeCode.toLowerCase().startsWith('en')
            ? (l10n?.english ?? 'English')
            : (l10n?.french ?? 'Français');
        final infoItems = [
          _InfoItem(
            icon: Icons.devices_other,
            label: l10n?.infoOs ?? 'OS',
            value: Platform.operatingSystem,
          ),
          _InfoItem(
            icon: Icons.terminal,
            label: l10n?.infoOsVersion ?? 'Version OS',
            value: Platform.operatingSystemVersion,
          ),
          _InfoItem(
            icon: Icons.memory,
            label: l10n?.infoArchitecture ?? 'Architecture',
            value: Platform.version.split(' ').first,
          ),
          _InfoItem(
            icon: Icons.monitor,
            label: l10n?.infoResolution ?? 'Resolution',
            value:
                '${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}',
          ),
          _InfoItem(
            icon: Icons.language,
            label: l10n?.infoLocale ?? 'Locale',
            value: localeLabel,
          ),
          _InfoItem(
            icon: Icons.video_library_outlined,
            label: l10n?.infoVideosCount ?? 'Videos',
            value: '${data['videoCount'] ?? 0}',
          ),
          _InfoItem(
            icon: Icons.verified_user_outlined,
            label: l10n?.infoTrial ?? 'Trial',
            value: data['trialInfo'] ?? 'n/a',
          ),
        ];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n?.infoOverviewTitle ?? 'Informations système',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.infoOverviewSubtitle ??
                  'Votre environnement et vos enregistrements en un coup d\'oeil.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: infoItems.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isWide ? 300 : 360,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: isWide ? 78 : 94,
                  ),
                  itemBuilder: (context, index) =>
                      _buildInfoCard(infoItems[index]),
                );
              },
            ),
            const SizedBox(height: 16),
            if (recordingsPath != null)
              _buildRecordingsCard(
                context,
                recordingsPath,
                l10n?.infoRecordingsFolder ?? 'Dossier des enregistrements',
                l10n?.infoOpenRecordingsFolder ?? 'Ouvrir le dossier',
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(_InfoItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.25,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsCard(
    BuildContext context,
    String path,
    String title,
    String buttonLabel,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openRecordingsFolder(path),
                icon: const Icon(Icons.open_in_new, color: Color(0xFF93C5FD)),
                label: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Color(0xFF93C5FD),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            path,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacAddresses(String label, List<String> macs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge_outlined, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (macs.isEmpty)
            const Text('n/a', style: TextStyle(color: Colors.white54))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: macs
                  .map(
                    (m) => Chip(
                      label: Text(m),
                      backgroundColor: Colors.white.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _gatherSystemInfo() async {
    final settings = ref.read(settingsProvider);
    final videos = await _videoService.listVideos();
    final recordingsPath = await _videoService.recordingsPath();
    final macs = await _storage.loadMacAddresses();
    final trialStart = await _storage.loadTrialStart();
    final fmt = DateFormat('yyyy-MM-dd');
    final trialInfo = trialStart == null
        ? 'Trial non initialisé'
        : 'Début: ${fmt.format(trialStart)} | Durée: ${bool.hasEnvironment("TRIAL_DAYS") ? int.fromEnvironment("TRIAL_DAYS") : 90} jours';

    return {
      'videoCount': videos.length,
      'recordingsPath': recordingsPath,
      'macs': macs,
      'trialInfo': trialInfo,
      'locale': settings.locale,
    };
  }

  Widget _buildVideoLibrary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final localeCode = settings.locale;
    final dateFormat = DateFormat.yMMMd(localeCode).add_Hm();
    final shareLabel = localeCode.toLowerCase().startsWith('en')
        ? 'Share'
        : 'Partager';
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_videosFuture, _videoService.recordingsPath()]),
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
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final files = (snapshot.data![0] as List<FileSystemEntity>?) ?? [];
        final recordingsPath = snapshot.data![1] as String? ?? '';

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openRecordingsFolder(recordingsPath),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF93C5FD),
                  ),
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    l10n?.infoOpenRecordingsFolder ?? 'Ouvrir le dossier',
                  ),
                ),
              ),
            ),
            Expanded(
              child: files.isEmpty
                  ? Center(
                      child: Text(
                        l10n?.videosEmpty ?? 'Aucune vidéo trouvée',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final name = file.uri.pathSegments.last;
                        return ListTile(
                          leading: const Icon(
                            Icons.video_library,
                            color: Colors.white70,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            dateFormat.format(file.statSync().modified),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () => _openPlayer(context, file.path),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Afficher dans le dossier',
                                icon: const Icon(
                                  Icons.folder_open,
                                  color: Colors.white70,
                                ),
                                onPressed: () => _revealFile(file),
                              ),
                              IconButton(
                                tooltip: shareLabel,
                                icon: const Icon(
                                  Icons.ios_share,
                                  color: Colors.white70,
                                ),
                                onPressed: () async {
                                  if (file is File && await file.exists()) {
                                    await Share.shareXFiles([
                                      XFile(file.path),
                                    ], text: name);
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'Supprimer',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteFile(context, file),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshVideos() async {
    setState(() {
      _videosFuture = _videoService.listVideos();
    });
  }

  Future<void> _deleteFile(BuildContext context, FileSystemEntity file) async {
    try {
      if (file is File && await file.exists()) {
        await file.delete();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Vidéo supprimée')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Suppression impossible: $e')));
      }
    } finally {
      await _refreshVideos();
    }
  }

  Future<void> _revealFile(FileSystemEntity file) async {
    if (file is! File || !await file.exists()) return;
    if (Platform.isMacOS) {
      await Process.run('open', ['-R', file.path]);
    } else if (Platform.isWindows) {
      // Convertir les slashes pour Windows
      final windowsPath = file.path.replaceAll('/', '\\');
      await Process.run('explorer', ['/select,', windowsPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [file.parent.path]);
    }
  }

  Future<void> _openRecordingsFolder(String path) async {
    try {
      if (path.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chemin de dossier indisponible')),
          );
        }
        return;
      }
      final dir = Directory(path);
      if (!await dir.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Dossier introuvable')));
        }
        return;
      }
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        // Convertir les slashes pour Windows et ouvrir le dossier
        final windowsPath = path.replaceAll('/', '\\');
        await Process.run('explorer', [windowsPath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le dossier: $e')),
        );
      }
    }
  }

  Future<void> _openPlayer(BuildContext context, String path) async {
    debugPrint('[UI] Opening video player for: $path');
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      controller.play();
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0f172a),
            content: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller!.pause();
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );
    } on UnimplementedError catch (e) {
      debugPrint('[UI] Video player not available on this platform: $e');
      await OpenFilex.open(path);
    } catch (e) {
      debugPrint('[UI] Error opening video player: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de lire la vidéo: $e')),
        );
      }
    } finally {
      await controller?.dispose();
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
