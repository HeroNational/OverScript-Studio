import Cocoa
import FlutterMacOS
import AVFoundation

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }

    let fullscreenChannel = FlutterMethodChannel(
      name: "com.overscript.studio/fullscreen",
      binaryMessenger: controller.engine.binaryMessenger
    )

    fullscreenChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "toggleFullscreen" {
        self?.toggleFullscreen(result: result)
      } else if call.method == "isFullscreen" {
        result(self?.mainFlutterWindow?.styleMask.contains(.fullScreen) ?? false)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    let captureChannel = FlutterMethodChannel(
      name: "com.overscript.studio/capture",
      binaryMessenger: controller.engine.binaryMessenger
    )

    captureChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "listVideoDevices" {
        result(self?.listVideoDevices() ?? [])
      } else if call.method == "listAudioDevices" {
        result(self?.listAudioDevices() ?? [])
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func toggleFullscreen(result: @escaping FlutterResult) {
    guard let window = mainFlutterWindow else {
      result(FlutterError(code: "FULLSCREEN_ERROR", message: "Window not found", details: nil))
      return
    }

    let isFullscreen = window.styleMask.contains(.fullScreen)
    if isFullscreen {
      window.toggleFullScreen(nil)
    } else {
      window.toggleFullScreen(nil)
    }

    result(nil)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  private func listVideoDevices() -> [[String: Any]] {
    var devices: [[String: Any]] = []
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: .video,
      position: .unspecified
    )

    for device in session.devices {
      devices.append([
        "id": device.uniqueID,
        "label": device.localizedName
      ])
    }

    NSLog("[AVFoundation] Found \(devices.count) video devices")
    for device in devices {
      NSLog("[AVFoundation] Video device: id=\(device["id"] ?? "unknown"), label=\(device["label"] ?? "unknown")")
    }

    return devices
  }

  private func listAudioDevices() -> [[String: Any]] {
    var devices: [[String: Any]] = []
    let session = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInMicrophone],
      mediaType: .audio,
      position: .unspecified
    )

    for device in session.devices {
      devices.append([
        "id": device.uniqueID,
        "label": device.localizedName
      ])
    }

    NSLog("[AVFoundation] Found \(devices.count) audio devices")
    for device in devices {
      NSLog("[AVFoundation] Audio device: id=\(device["id"] ?? "unknown"), label=\(device["label"] ?? "unknown")")
    }

    return devices
  }
}
