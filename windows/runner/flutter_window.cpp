#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project), desktop_recorder_(std::make_unique<DesktopRecorder>()) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Setup desktop recorder method channel
  const std::string channel_name = "com.overscript.studio/desktop_recorder";
  recorder_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  recorder_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "startRecording") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!arguments) {
            result->Error("BAD_ARGS", "Arguments missing");
            return;
          }

          std::string path;
          std::string video_id;
          std::string audio_id;
          int fps = 0;

          auto path_it = arguments->find(flutter::EncodableValue("path"));
          if (path_it != arguments->end()) {
            const auto* path_str = std::get_if<std::string>(&path_it->second);
            if (path_str) path = *path_str;
          }

          auto video_it = arguments->find(flutter::EncodableValue("videoDeviceId"));
          if (video_it != arguments->end()) {
            const auto* video_str = std::get_if<std::string>(&video_it->second);
            if (video_str) video_id = *video_str;
          }

          auto audio_it = arguments->find(flutter::EncodableValue("audioDeviceId"));
          if (audio_it != arguments->end()) {
            const auto* audio_str = std::get_if<std::string>(&audio_it->second);
            if (audio_str) audio_id = *audio_str;
          }

          auto fps_it = arguments->find(flutter::EncodableValue("fps"));
          if (fps_it != arguments->end()) {
            if (const auto* fps_val = std::get_if<int32_t>(&fps_it->second)) {
              fps = *fps_val;
            } else if (const auto* fps_double = std::get_if<double>(&fps_it->second)) {
              fps = static_cast<int>(*fps_double);
            }
          }

          desktop_recorder_->StartRecording(path, video_id, audio_id, fps, std::move(result));
        } else if (call.method_name() == "stopRecording") {
          desktop_recorder_->StopRecording(std::move(result));
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
