import Cocoa
import FlutterMacOS

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
}
