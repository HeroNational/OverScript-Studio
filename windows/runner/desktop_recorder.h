#ifndef DESKTOP_RECORDER_H_
#define DESKTOP_RECORDER_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

class DesktopRecorder {
 public:
  DesktopRecorder();
  ~DesktopRecorder();

  void StartRecording(
      const std::string& output_path,
      const std::string& video_device_id,
      const std::string& audio_device_id,
      int fps,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void StopRecording(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  class Impl;
  std::unique_ptr<Impl> impl_;
};

#endif  // DESKTOP_RECORDER_H_
