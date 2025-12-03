import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/services.dart';

class CaptureDeviceInfo {
  final String id;
  final String label;
  CaptureDeviceInfo(this.id, this.label);
}

/// Service de capture vidéo/audio.
/// Mobile : plugin camera.
/// Desktop : preview via WebRTC (pas d'enregistrement fichier dans cette version).
class CaptureService {
  static const MethodChannel _desktopRecorderChannel = MethodChannel('com.overscript.studio/desktop_recorder');
  CameraController? _controller;
  bool _recording = false;
  MediaStream? _desktopStream;
  RTCVideoRenderer? _desktopRenderer;
  MediaRecorder? _desktopRecorder;
  String? _desktopRecordingPath;
  bool get _isMac => Platform.isMacOS;

  CameraController? get controller => _controller;
  bool get isRecording => _recording;
  bool get isInitialized => _controller?.value.isInitialized ?? (_desktopRenderer != null);
  RTCVideoRenderer? get desktopRenderer => _desktopRenderer;

  /// Liste les caméras disponibles.
  Future<List<CaptureDeviceInfo>> listVideoDevices() async {
    if (_isDesktop) {
      try {
        final devices = await navigator.mediaDevices.enumerateDevices();
        final cams = devices
            .where((d) => d.kind == 'videoinput')
            .map((d) => CaptureDeviceInfo(d.deviceId, d.label.isNotEmpty ? d.label : d.deviceId))
            .toList();
        if (cams.isNotEmpty) return cams;
      } catch (_) {}
      return [CaptureDeviceInfo('default', 'Caméra système')];
    }
    final cams = await availableCameras();
    return cams
        .map((camera) {
          final label = camera.lensDirection == CameraLensDirection.front
              ? 'Front Camera'
              : camera.lensDirection == CameraLensDirection.back
                  ? 'Back Camera'
                  : 'External Camera';
          return CaptureDeviceInfo(camera.name, label);
        })
        .toList();
  }

  /// Liste les micros disponibles.
  Future<List<CaptureDeviceInfo>> listAudioDevices() async {
    if (_isDesktop) {
      try {
        final devices = await navigator.mediaDevices.enumerateDevices();
        final mics = devices
            .where((d) => d.kind == 'audioinput')
            .map((d) => CaptureDeviceInfo(d.deviceId, d.label.isNotEmpty ? d.label : d.deviceId))
            .toList();
        if (mics.isNotEmpty) return mics;
      } catch (_) {}
      return [CaptureDeviceInfo('default', 'Micro système')];
    }
    return [CaptureDeviceInfo('default', 'Micro par défaut')];
  }

  /// Démarre la preview (sans enregistrement).
  Future<void> startPreview({String? cameraId, String? micId}) async {
    if (!await _ensurePermissions()) return;
    if (_isDesktop) {
      await _startPreviewDesktop(cameraId: cameraId, micId: micId);
    } else {
      await _startPreviewMobile(cameraId: cameraId);
    }
  }

  /// Stoppe uniquement la preview (sans toucher à l’état d’enregistrement).
  Future<void> stopPreview() async {
    if (_isDesktop) {
      await _stopPreviewDesktop();
      return;
    }
    if (_controller != null) {
      await _controller?.dispose();
      _controller = null;
    }
  }

  /// Démarre l’enregistrement (init preview si besoin).
  Future<void> startCapture({String? cameraId, String? micId}) async {
    if (!await _ensurePermissions()) return;
    if (_isMac) {
      await _startPreviewDesktop(cameraId: cameraId, micId: micId);
      try {
        final path = await _desktopRecordPath();
        _desktopRecordingPath = path;
        await _desktopRecorderChannel.invokeMethod('startRecording', {
          'path': path,
          'videoDeviceId': cameraId,
          'audioDeviceId': micId,
        });
        _recording = true;
      } catch (_) {
        _recording = false;
        _desktopRecordingPath = null;
        throw Exception('Desktop recording not supported on this platform');
      }
      return;
    }
    if (_isDesktop) {
      await _startPreviewDesktop(cameraId: cameraId, micId: micId);
      // Tentative d’enregistrement desktop via MediaRecorder (si supporté par le runtime)
      try {
        _desktopRecorder = MediaRecorder();
        final track = _desktopStream?.getVideoTracks().isNotEmpty == true
            ? _desktopStream!.getVideoTracks().first
            : null;
        final path = await _desktopRecordPath();
        _desktopRecordingPath = path;
        await _desktopRecorder!.start(path, videoTrack: track, audioChannel: RecorderAudioChannel.INPUT);
        _recording = true;
      } catch (_) {
        _recording = false;
        _desktopRecordingPath = null;
        throw Exception('Desktop recording not supported on this platform');
      }
    } else {
      await _startCaptureMobile(cameraId: cameraId);
    }
  }

  Future<String?> stopCapture() async {
    if (_isMac) {
      try {
        final path = await _desktopRecorderChannel.invokeMethod<String>('stopRecording');
        _recording = false;
        _desktopRecordingPath = null;
        await _stopPreviewDesktop();
        if (path != null && File(path).existsSync()) {
          return path;
        }
        return null;
      } catch (_) {
        _recording = false;
        _desktopRecordingPath = null;
        await _stopPreviewDesktop();
        return null;
      }
    }
    if (_isDesktop) {
      try {
        if (_desktopRecorder != null && _recording) {
          await _desktopRecorder!.stop();
        }
      } catch (_) {}
      await _stopPreviewDesktop();
      final path = _desktopRecordingPath;
      _desktopRecordingPath = null;
      _recording = false;
      if (path != null && File(path).existsSync()) {
        return path;
      }
      return null;
    }
    if (_controller == null || !_recording) return null;
    try {
      final file = await _controller!.stopVideoRecording();
      _recording = false;
      final recordingsDir = await _ensureRecordingsDir();
      final targetPath = '${recordingsDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await file.saveTo(targetPath);
      return targetPath;
    } catch (_) {
      _recording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      if (_recording && _controller != null) {
        await _controller?.stopVideoRecording();
      }
      await _controller?.dispose();
      await _stopPreviewDesktop();
      _desktopRecorder = null;
      _desktopRecordingPath = null;
    } finally {
      _controller = null;
      _recording = false;
    }
  }

  Future<void> _startPreviewMobile({String? cameraId}) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    // Dispose l’ancienne preview si on change de caméra
    if (_controller != null) {
      await _controller?.dispose();
      _controller = null;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }
    CameraDescription selected = cameras.first;
    if (cameraId != null) {
      final match = cameras.where((c) => c.name == cameraId).toList();
      if (match.isNotEmpty) selected = match.first;
    }
    _controller = CameraController(
      selected,
      ResolutionPreset.medium,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
  }

  Future<void> _startCaptureMobile({String? cameraId}) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await _startPreviewMobile(cameraId: cameraId);
    }
    if (_controller == null) throw Exception('Camera init failed');
    await _controller!.prepareForVideoRecording();
    await _controller!.startVideoRecording();
    _recording = true;
  }

  // Desktop preview helpers (WebRTC)
  Future<void> _startPreviewDesktop({String? cameraId, String? micId}) async {
    // dispose previous
    await _stopPreviewDesktop();
    _desktopRenderer = RTCVideoRenderer();
    await _desktopRenderer!.initialize();

    final constraints = {
      'audio': micId != null && micId.isNotEmpty
          ? {
              'deviceId': micId,
              'echoCancellation': true,
            }
          : true,
      'video': cameraId != null && cameraId.isNotEmpty
          ? {
              'deviceId': cameraId,
              'width': 1280,
              'height': 720,
            }
          : {
              'facingMode': 'user',
              'width': 1280,
              'height': 720,
            },
    };

    try {
      _desktopStream = await navigator.mediaDevices.getUserMedia(constraints);
    } catch (_) {
      // Fallback sans deviceId si la contrainte échoue
      _desktopStream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': true});
    }
    _desktopRenderer!.srcObject = _desktopStream;
  }

  Future<void> _stopPreviewDesktop() async {
    try {
      _desktopStream?.getTracks().forEach((t) => t.stop());
      _desktopStream = null;
      await _desktopRenderer?.dispose();
    } finally {
      _desktopRenderer = null;
    }
  }

  Future<Directory> _ensureRecordingsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/OverScriptStudio/Recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _desktopRecordPath() async {
    final dir = await _ensureRecordingsDir();
    return '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  /// Liste les enregistrements sauvegardés.
  Future<List<FileSystemEntity>> listRecordings() async {
    final dir = await _ensureRecordingsDir();
    if (!await dir.exists()) return [];
    final files = dir.listSync().whereType<File>().toList();
    files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  /// Supprime un enregistrement
  Future<void> deleteRecording(FileSystemEntity file) async {
    if (file.existsSync()) {
      await file.delete();
    }
  }

  bool get _isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<bool> _ensurePermissions() async {
    if (_isDesktop) return true;
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    final camOk = statuses[Permission.camera]?.isGranted ?? false;
    final micOk = statuses[Permission.microphone]?.isGranted ?? false;
    return camOk && micOk;
  }
}
