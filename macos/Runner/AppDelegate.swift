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

    let recorderChannel = FlutterMethodChannel(
      name: "com.overscript.studio/desktop_recorder",
      binaryMessenger: controller.engine.binaryMessenger
    )

    recorderChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "BAD_ARGS", message: "Arguments manquants", details: nil))
        return
      }
      switch call.method {
      case "startRecording":
        let path = args["path"] as? String
        let videoId = args["videoDeviceId"] as? String
        let audioId = args["audioDeviceId"] as? String
        self?.recorder.start(path: path, videoId: videoId, audioId: audioId, result: result)
      case "stopRecording":
        self?.recorder.stop(result: result)
      default:
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

  // MARK: - Recorder helper
  private let recorder = DesktopRecorder()
}

class DesktopRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
  private let session = AVCaptureSession()
  private let movieOutput = AVCaptureMovieFileOutput()
  private var currentResult: FlutterResult?

  private func ensurePermissions(completion: @escaping (Bool) -> Void) {
    let group = DispatchGroup()
    var videoGranted = false
    var audioGranted = false

    func request(_ mediaType: AVMediaType, setter: @escaping (Bool) -> Void) {
      let status = AVCaptureDevice.authorizationStatus(for: mediaType)
      switch status {
      case .authorized:
        setter(true)
      case .notDetermined:
        group.enter()
        AVCaptureDevice.requestAccess(for: mediaType) { granted in
          setter(granted)
          group.leave()
        }
      default:
        setter(false)
      }
    }

    request(.video) { granted in videoGranted = granted }
    request(.audio) { granted in audioGranted = granted }

    group.notify(queue: .main) {
      completion(videoGranted && audioGranted)
    }
  }

  func start(path: String?, videoId: String?, audioId: String?, result: @escaping FlutterResult) {
    guard let path = path else {
      result(FlutterError(code: "NO_PATH", message: "Chemin manquant", details: nil))
      return
    }

    ensurePermissions { granted in
      guard granted else {
        result(FlutterError(code: "PERMISSION_DENIED", message: "Autorisez la caméra et le micro dans Préférences Système", details: nil))
        return
      }

      self.startWithGrantedPermissions(path: path, videoId: videoId, audioId: audioId, result: result)
    }
  }

  private func startWithGrantedPermissions(path: String, videoId: String?, audioId: String?, result: @escaping FlutterResult) {
    session.beginConfiguration()
    session.sessionPreset = .high

    // Clear previous inputs
    for input in session.inputs {
      session.removeInput(input)
    }

    do {
      let videoDevice = videoId.flatMap { AVCaptureDevice(uniqueID: $0) } ?? AVCaptureDevice.default(for: .video)
      if let v = videoDevice {
        let videoInput = try AVCaptureDeviceInput(device: v)
        if session.canAddInput(videoInput) { session.addInput(videoInput) }
      }

      let audioDevice = audioId.flatMap { AVCaptureDevice(uniqueID: $0) } ?? AVCaptureDevice.default(for: .audio)
      if let a = audioDevice {
        let audioInput = try AVCaptureDeviceInput(device: a)
        if session.canAddInput(audioInput) { session.addInput(audioInput) }
      }
    } catch {
      session.commitConfiguration()
      result(FlutterError(code: "INPUT_ERROR", message: "Impossible d'ajouter les entrées", details: error.localizedDescription))
      return
    }

    if session.canAddOutput(movieOutput) && !session.outputs.contains(movieOutput) {
      session.addOutput(movieOutput)
    }

    session.commitConfiguration()

    // Start session
    if !session.isRunning {
      session.startRunning()
    }

    let url = URL(fileURLWithPath: path)
    NSLog("[DesktopRecorder] Starting recording to path: \(path)")
    movieOutput.startRecording(to: url, recordingDelegate: self)
    NSLog("[DesktopRecorder] Recording started, isRecording: \(movieOutput.isRecording)")
    // Return immediately to Flutter, don't wait for the recording to finish
    result(path)
  }

  func stop(result: @escaping FlutterResult) {
    NSLog("[DesktopRecorder] Stop requested, isRecording: \(movieOutput.isRecording)")
    guard movieOutput.isRecording else {
      NSLog("[DesktopRecorder] Not recording, returning nil")
      result(nil)
      return
    }
    NSLog("[DesktopRecorder] Stopping recording...")
    // Store the result to return when recording finishes
    currentResult = result
    movieOutput.stopRecording()
    session.stopRunning()
  }

  func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    NSLog("[DesktopRecorder] Recording finished, path: \(outputFileURL.path), error: \(error?.localizedDescription ?? "none")")
    // Only return result if stop() was called (currentResult will be set)
    if let result = currentResult {
      if let error = error {
        NSLog("[DesktopRecorder] Returning error to Flutter: \(error.localizedDescription)")
        result(FlutterError(code: "RECORD_ERROR", message: error.localizedDescription, details: nil))
      } else {
        NSLog("[DesktopRecorder] Returning path to Flutter: \(outputFileURL.path)")
        result(outputFileURL.path)
      }
      currentResult = nil
    } else {
      NSLog("[DesktopRecorder] Recording finished but no result callback waiting")
    }
  }
}
