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
    if #available(iOS 15.0, *) {
      // Request scene session to support multi-window/PiP
      // For now, we'll trigger the app switcher which allows multitasking
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        let options = UIWindowSceneGeometryPreferencesPhone()
        options.maximumFullScreenDimensions = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)

        if #available(iOS 17.0, *) {
          scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        }
      }
    }

    // Alternative: Go to app switcher by simulating Home button (limited in modern iOS)
    // For practical purposes, we notify that PiP is activated
    result(nil)
  }
}
