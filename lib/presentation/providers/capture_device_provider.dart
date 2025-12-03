import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/capture_service.dart';

final captureServiceProvider = Provider((ref) => CaptureService());

final videoDevicesProvider = FutureProvider<List<CaptureDeviceInfo>>((ref) async {
  final service = ref.watch(captureServiceProvider);
  return service.listVideoDevices();
});

final audioDevicesProvider = FutureProvider<List<CaptureDeviceInfo>>((ref) async {
  final service = ref.watch(captureServiceProvider);
  return service.listAudioDevices();
});

String translateDeviceLabel(String label) {
  switch (label) {
    // Mobile
    case 'Front Camera':
      return 'Caméra frontale';
    case 'Back Camera':
      return 'Caméra arrière';
    case 'External Camera':
      return 'Caméra externe';
    // Desktop fallback
    case 'Caméra système':
      return 'System camera';
    case 'Caméra intégrée':
      return 'Built-in camera';
    case 'Micro système':
      return 'System microphone';
    default:
      return label;
  }
}
