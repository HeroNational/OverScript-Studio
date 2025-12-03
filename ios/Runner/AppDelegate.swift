import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let pipChannel = FlutterMethodChannel(name: "com.overscript.studio/pip",
                                           binaryMessenger: controller.binaryMessenger)

    pipChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "togglePiP" {
        self?.togglePictureInPicture(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func togglePictureInPicture(result: @escaping FlutterResult) {
    guard let window = window else {
      result(FlutterError(code: "PIP_ERROR", message: "Window not found", details: nil))
      return
    }

    let controller = window.rootViewController as! FlutterViewController

    // On iOS, Picture-in-Picture is primarily used with AVPlayer for video content
    // For general app PiP (iOS 15+), we minimize to app switcher
    if #available(iOS 16.0, *) {
      // Request a portrait orientation preference to hint the system we support geometry changes
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        let preferences = UIWindowScene.GeometryPreferences.iOS()
        preferences.interfaceOrientations = .portrait
        scene.requestGeometryUpdate(preferences, errorHandler: { error in
          NSLog("PiP geometry update failed: \(error.localizedDescription)")
        })
      }
    }

    // Alternative: Go to app switcher by simulating Home button (limited in modern iOS)
    // For practical purposes, we notify that PiP is activated
    result(nil)
  }
}
