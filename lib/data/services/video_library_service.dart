import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoLibraryService {
  /// Retourne le dossier où stocker/chercher les vidéos enregistrées.
  Future<Directory> _getVideosDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/OverScriptStudio/Recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Liste les fichiers vidéo connus (formats classiques).
  Future<List<FileSystemEntity>> listVideos() async {
    final dir = await _getVideosDir();
    final entries = await dir.list().toList();
    final videoExt = <String>{'.mp4', '.mov', '.mkv', '.avi'};
    return entries.where((e) {
      if (e is! File) return false;
      final name = e.path.toLowerCase();
      return videoExt.any((ext) => name.endsWith(ext));
    }).toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
  }

  /// Retourne le chemin du dossier des enregistrements.
  Future<String> recordingsPath() async {
    final dir = await _getVideosDir();
    return dir.path;
  }
}
