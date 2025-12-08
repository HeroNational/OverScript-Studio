#include "desktop_recorder.h"

#include <iostream>
#include <thread>
#include <atomic>
#include <chrono>
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <shlwapi.h>
#include <shlobj.h>
#include <windows.h>
#include <wmcodecdsp.h>

#pragma comment(lib, "mfplat.lib")
#pragma comment(lib, "mf.lib")
#pragma comment(lib, "mfreadwrite.lib")
#pragma comment(lib, "mfuuid.lib")
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "ole32.lib")

// Internal implementation using Media Foundation
class DesktopRecorder::Impl {
 public:
  Impl() : mf_initialized_(false) {
    is_recording_.store(false);
    HRESULT hr = MFStartup(MF_VERSION);
    if (SUCCEEDED(hr)) {
      mf_initialized_ = true;
      std::cout << "[DesktopRecorder] Media Foundation initialized" << std::endl;
    } else {
      std::cerr << "[DesktopRecorder] Failed to initialize Media Foundation: " << hr << std::endl;
    }
  }

  ~Impl() {
    if (is_recording_) {
      StopRecording();
    }
    if (mf_initialized_) {
      MFShutdown();
    }
  }

  void StartRecording(
      const std::string& output_path,
      const std::string& video_device_id,
      const std::string& audio_device_id,
      int fps,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {

    // Ensure COM is initialized on this thread (Flutter platform thread may not be)
    HRESULT hrCo = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    bool comInitialized = SUCCEEDED(hrCo) || hrCo == RPC_E_CHANGED_MODE;

    if (!mf_initialized_) {
      result->Error("MF_NOT_INITIALIZED", "Media Foundation not initialized");
      if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
        CoUninitialize();
      }
      return;
    }

    if (is_recording_) {
      result->Error("ALREADY_RECORDING", "Already recording");
      if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
        CoUninitialize();
      }
      return;
    }

    std::cout << "[DesktopRecorder] Starting recording to: " << output_path << std::endl;

    // Convert std::string to std::wstring for Windows API
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, output_path.c_str(), (int)output_path.length(), NULL, 0);
    std::wstring wpath(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, output_path.c_str(), (int)output_path.length(), &wpath[0], size_needed);

    // Ensure output directory exists
    std::wstring dir_path = wpath.substr(0, wpath.find_last_of(L"\\/"));
    SHCreateDirectoryExW(NULL, dir_path.c_str(), NULL);

    // Create sink writer
    IMFSinkWriter* pSinkWriter = NULL;

    HRESULT hr = MFCreateSinkWriterFromURL(wpath.c_str(), NULL, NULL, &pSinkWriter);

    if (FAILED(hr)) {
      std::cerr << "[DesktopRecorder] Failed to create sink writer: " << hr << std::endl;
      result->Error("SINK_WRITER_FAILED", "Failed to create sink writer");
      return;
    }

    // We'll configure output media type after getting camera resolution
    // Placeholder for video stream index
    DWORD videoStreamIndex = 0;

    // Create video capture source FIRST to get native resolution
    IMFActivate* pActivate = FindVideoCaptureDevice(video_device_id);
    if (!pActivate) {
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] No video capture device found" << std::endl;
      result->Error("NO_CAMERA", "No video capture device found");
      return;
    }

    IMFMediaSource* pSource = NULL;
    hr = pActivate->ActivateObject(__uuidof(IMFMediaSource), (void**)&pSource);
    pActivate->Release();

    if (FAILED(hr)) {
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to activate video source: " << hr << std::endl;
      result->Error("SOURCE_ACTIVATION_FAILED", "Failed to activate video source");
      return;
    }

    // Create source reader
    IMFAttributes* pReaderAttributes = NULL;
    MFCreateAttributes(&pReaderAttributes, 1);
    if (pReaderAttributes) {
      pReaderAttributes->SetUINT32(MF_READWRITE_ENABLE_HARDWARE_TRANSFORMS, TRUE);
    }

    IMFSourceReader* pReader = NULL;
    hr = MFCreateSourceReaderFromMediaSource(pSource, pReaderAttributes, &pReader);

    if (pReaderAttributes) {
      pReaderAttributes->Release();
    }
    pSource->Release();

    if (FAILED(hr)) {
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to create source reader: " << hr << std::endl;
      result->Error("READER_CREATION_FAILED", "Failed to create source reader");
      return;
    }

    // Get the native media type from the camera
    IMFMediaType* pNativeType = NULL;
    hr = pReader->GetNativeMediaType((DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM, 0, &pNativeType);

    if (FAILED(hr) || !pNativeType) {
      pReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to get native media type" << std::endl;
      result->Error("NO_NATIVE_TYPE", "Failed to get camera format");
      return;
    }

    // Enumerate native media types to pick the highest resolution available
    GUID subtype = MFVideoFormat_NV12;
    UINT32 width = 0, height = 0;
    UINT32 frameRateNum = 0, frameRateDen = 0;
    double bestPixels = 0.0;
    if (pNativeType) {
      pNativeType->Release();
      pNativeType = NULL;
    }
    for (DWORD idx = 0;; idx++) {
      IMFMediaType* pCandidate = NULL;
      HRESULT hrCandidate = pReader->GetNativeMediaType((DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM, idx, &pCandidate);
      if (FAILED(hrCandidate) || !pCandidate) break;

      UINT32 w = 0, h = 0;
      GUID st;
      MFGetAttributeSize(pCandidate, MF_MT_FRAME_SIZE, &w, &h);
      pCandidate->GetGUID(MF_MT_SUBTYPE, &st);
      double pixels = static_cast<double>(w) * static_cast<double>(h);
      double score = pixels;
      if (st == MFVideoFormat_MJPG || st == MFVideoFormat_NV12) score *= 1.05;

      if (score > bestPixels) {
        if (pNativeType) pNativeType->Release();
        pNativeType = pCandidate;
        width = w;
        height = h;
        subtype = st;
        bestPixels = score;
      } else {
        pCandidate->Release();
      }
    }

    if (!pNativeType) {
      pReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to get native media type" << std::endl;
      result->Error("NO_NATIVE_TYPE", "Failed to get camera format");
      return;
    }

    if (fps > 0) {
      frameRateNum = static_cast<UINT32>(fps);
      frameRateDen = 1;
      frame_duration_ = 10000000LL / fps;
    } else if (SUCCEEDED(MFGetAttributeRatio(pNativeType, MF_MT_FRAME_RATE, &frameRateNum, &frameRateDen)) &&
               frameRateNum > 0) {
      frame_duration_ = (10000000LL * frameRateDen) / frameRateNum; // 100ns units
    } else {
      frameRateNum = 30;
      frameRateDen = 1;
      frame_duration_ = 10000000LL / 30; // fallback to 30fps
    }

    std::cout << "[DesktopRecorder] Chosen format: ";
    if (subtype == MFVideoFormat_YUY2) std::cout << "YUY2";
    else if (subtype == MFVideoFormat_NV12) std::cout << "NV12";
    else if (subtype == MFVideoFormat_RGB32) std::cout << "RGB32";
    else if (subtype == MFVideoFormat_MJPG) std::cout << "MJPG";
    else std::cout << "Unknown";
    std::cout << " " << width << "x" << height << " @" << frameRateNum << "fps" << std::endl;

    // Use at least 1280x720 if camera reports very low resolution
    if (width < 640 || height < 360) {
      width = 1280;
      height = 720;
      std::cout << "[DesktopRecorder] Forcing minimum 720p resolution fallback" << std::endl;
    }

    // Configure reader output to use YUY2 or NV12 at native resolution
    IMFMediaType* pReaderOutputType = NULL;
    hr = MFCreateMediaType(&pReaderOutputType);
    if (SUCCEEDED(hr)) {
      pReaderOutputType->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video);
      GUID preferredSubtype = MFVideoFormat_NV12;
      if (subtype == MFVideoFormat_MJPG) preferredSubtype = MFVideoFormat_MJPG;
      pReaderOutputType->SetGUID(MF_MT_SUBTYPE, preferredSubtype);
      MFSetAttributeSize(pReaderOutputType, MF_MT_FRAME_SIZE, width, height);
      MFSetAttributeRatio(pReaderOutputType, MF_MT_FRAME_RATE, frameRateNum, frameRateDen);

      hr = pReader->SetCurrentMediaType((DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM, NULL, pReaderOutputType);

      if (FAILED(hr) && preferredSubtype != subtype) {
        std::cout << "[DesktopRecorder] Preferred subtype failed, trying native..." << std::endl;
        pReaderOutputType->SetGUID(MF_MT_SUBTYPE, subtype);
        hr = pReader->SetCurrentMediaType((DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM, NULL, pReaderOutputType);
      }
    }

    pNativeType->Release();

    // Store resolution for later use
    video_width_ = width;
    video_height_ = height;

    if (FAILED(hr) || !pReaderOutputType) {
      if (pReaderOutputType) pReaderOutputType->Release();
      pReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to configure source reader format: " << hr << std::endl;
      result->Error("READER_TYPE_FAILED", "Failed to configure source reader");
      return;
    }

    // Now configure video output stream with detected resolution
    IMFMediaType* pVideoTypeOut = NULL;
    hr = MFCreateMediaType(&pVideoTypeOut);
    if (SUCCEEDED(hr)) {
      pVideoTypeOut->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Video);
      pVideoTypeOut->SetGUID(MF_MT_SUBTYPE, MFVideoFormat_H264);
      const UINT32 targetFps = frameRateNum > 0 ? frameRateNum : 30;
      // Adjust bitrate based on resolution; floor at 5 Mbps to improve quality
      UINT32 bitrate = static_cast<UINT32>(width * height * targetFps / 8); // ~0.125 bpp
      const UINT32 minBitrate = 5'000'000;  // 5 Mbps floor
      if (bitrate < minBitrate) bitrate = minBitrate;
      pVideoTypeOut->SetUINT32(MF_MT_AVG_BITRATE, bitrate);
      pVideoTypeOut->SetUINT32(MF_MT_INTERLACE_MODE, MFVideoInterlace_Progressive);
      MFSetAttributeSize(pVideoTypeOut, MF_MT_FRAME_SIZE, width, height);
      MFSetAttributeRatio(pVideoTypeOut, MF_MT_FRAME_RATE, targetFps, 1);
      MFSetAttributeRatio(pVideoTypeOut, MF_MT_PIXEL_ASPECT_RATIO, 1, 1);

      hr = pSinkWriter->AddStream(pVideoTypeOut, &videoStreamIndex);
      pVideoTypeOut->Release();
    }

    if (FAILED(hr)) {
      pReaderOutputType->Release();
      pReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to add video stream: " << hr << std::endl;
      result->Error("VIDEO_STREAM_FAILED", "Failed to add video stream");
      return;
    }

    // Configure the SinkWriter video input to match reader output
    hr = pSinkWriter->SetInputMediaType(videoStreamIndex, pReaderOutputType, NULL);
    pReaderOutputType->Release();

    if (FAILED(hr)) {
      pReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to set sink writer input type: " << hr << std::endl;
      result->Error("INPUT_TYPE_FAILED", "Failed to configure encoder input");
      return;
    }

    // Setup audio capture using default device when none specified
    IMFSourceReader* pAudioReader = NULL;
    DWORD audioStreamIndex = 0;
    IMFActivate* pAudioActivate = FindAudioCaptureDevice(audio_device_id);
    if (pAudioActivate) {
      IMFMediaSource* pAudioSource = NULL;
      hr = pAudioActivate->ActivateObject(__uuidof(IMFMediaSource), (void**)&pAudioSource);
      pAudioActivate->Release();

      if (SUCCEEDED(hr)) {
        hr = MFCreateSourceReaderFromMediaSource(pAudioSource, NULL, &pAudioReader);
        pAudioSource->Release();

        if (SUCCEEDED(hr)) {
          // Get native audio format first
          IMFMediaType* pNativeAudioType = NULL;
          hr = pAudioReader->GetNativeMediaType((DWORD)MF_SOURCE_READER_FIRST_AUDIO_STREAM, 0, &pNativeAudioType);

          UINT32 sampleRate = 44100;
          UINT32 numChannels = 2;

          if (SUCCEEDED(hr) && pNativeAudioType) {
            pNativeAudioType->GetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, &sampleRate);
            pNativeAudioType->GetUINT32(MF_MT_AUDIO_NUM_CHANNELS, &numChannels);
            pNativeAudioType->Release();
            std::cout << "[DesktopRecorder] Audio native format: " << sampleRate << "Hz, " << numChannels << " channels" << std::endl;
          }

          // Configure audio output stream (AAC)
          IMFMediaType* pAudioTypeOut = NULL;
          hr = MFCreateMediaType(&pAudioTypeOut);
          if (SUCCEEDED(hr)) {
            pAudioTypeOut->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
            pAudioTypeOut->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_AAC);
            pAudioTypeOut->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, sampleRate);
            pAudioTypeOut->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, numChannels);
            pAudioTypeOut->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16);
            pAudioTypeOut->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, 12000);
            pAudioTypeOut->SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, 1);

            hr = pSinkWriter->AddStream(pAudioTypeOut, &audioStreamIndex);
            pAudioTypeOut->Release();

            if (SUCCEEDED(hr)) {
              // Configure audio input (PCM)
              IMFMediaType* pAudioTypeIn = NULL;
              hr = MFCreateMediaType(&pAudioTypeIn);
              if (SUCCEEDED(hr)) {
                pAudioTypeIn->SetGUID(MF_MT_MAJOR_TYPE, MFMediaType_Audio);
                pAudioTypeIn->SetGUID(MF_MT_SUBTYPE, MFAudioFormat_PCM);
                pAudioTypeIn->SetUINT32(MF_MT_AUDIO_SAMPLES_PER_SECOND, sampleRate);
                pAudioTypeIn->SetUINT32(MF_MT_AUDIO_NUM_CHANNELS, numChannels);
                pAudioTypeIn->SetUINT32(MF_MT_AUDIO_BITS_PER_SAMPLE, 16);
                UINT32 blockAlign = numChannels * 2; // 16 bits = 2 bytes
                pAudioTypeIn->SetUINT32(MF_MT_AUDIO_BLOCK_ALIGNMENT, blockAlign);
                pAudioTypeIn->SetUINT32(MF_MT_AUDIO_AVG_BYTES_PER_SECOND, sampleRate * blockAlign);

                hr = pSinkWriter->SetInputMediaType(audioStreamIndex, pAudioTypeIn, NULL);
                if (SUCCEEDED(hr)) {
                  hr = pAudioReader->SetCurrentMediaType((DWORD)MF_SOURCE_READER_FIRST_AUDIO_STREAM, NULL, pAudioTypeIn);
                }
                pAudioTypeIn->Release();
              }

              if (SUCCEEDED(hr)) {
                std::cout << "[DesktopRecorder] Audio capture configured successfully" << std::endl;
              } else {
                std::cerr << "[DesktopRecorder] Audio configuration failed: 0x" << std::hex << hr << std::dec << std::endl;
                pAudioReader->Release();
                pAudioReader = NULL;
              }
            } else {
              std::cerr << "[DesktopRecorder] Failed to add audio stream: 0x" << std::hex << hr << std::dec << std::endl;
            }
          }
        }
      }
    }
    if (!pAudioReader) {
      std::cout << "[DesktopRecorder] Audio capture not available, recording video only" << std::endl;
    }

    // Begin writing
    hr = pSinkWriter->BeginWriting();
    if (FAILED(hr)) {
      pReader->Release();
      if (pAudioReader) pAudioReader->Release();
      pSinkWriter->Release();
      std::cerr << "[DesktopRecorder] Failed to begin writing: " << hr << std::endl;
      result->Error("BEGIN_WRITING_FAILED", "Failed to begin writing");
      return;
    }

    // Store for later use
    sink_writer_ = pSinkWriter;
    source_reader_ = pReader;
    audio_reader_ = pAudioReader;
    video_stream_index_ = videoStreamIndex;
    audio_stream_index_ = audioStreamIndex;
    output_path_ = output_path;
    is_recording_ = true;

    // Start capture thread
    capture_thread_ = std::thread(&Impl::CaptureThreadFunc, this);

    std::cout << "[DesktopRecorder] Recording started successfully with camera capture" << std::endl;
    result->Success(flutter::EncodableValue(output_path));

    if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
      CoUninitialize();
    }
  }

  void StopRecording() {
    // Ensure COM is initialized on this thread before touching MF objects
    HRESULT hrCo = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    bool comInitialized = SUCCEEDED(hrCo) || hrCo == RPC_E_CHANGED_MODE;

    if (!is_recording_) {
      if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
        CoUninitialize();
      }
      return;
    }

    std::cout << "[DesktopRecorder] Stopping recording..." << std::endl;

    // Signal to stop recording
    is_recording_ = false;

    // Wait for capture thread to finish
    if (capture_thread_.joinable()) {
      std::cout << "[DesktopRecorder] Waiting for capture thread..." << std::endl;
      capture_thread_.join();
      std::cout << "[DesktopRecorder] Capture thread joined" << std::endl;
    }

    // Finalize the sink writer
    if (sink_writer_) {
      HRESULT hr = sink_writer_->Finalize();
      if (FAILED(hr)) {
        std::cerr << "[DesktopRecorder] Failed to finalize sink writer: " << hr << std::endl;
      }
      sink_writer_->Release();
      sink_writer_ = nullptr;
    }

    // Release source readers
    if (source_reader_) {
      source_reader_->Release();
      source_reader_ = nullptr;
    }

    if (audio_reader_) {
      audio_reader_->Release();
      audio_reader_ = nullptr;
    }

    std::cout << "[DesktopRecorder] Recording stopped" << std::endl;

    if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
      CoUninitialize();
    }
  }

  void StopRecordingWithResult(
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    // Ensure COM is initialized on this thread before touching MF objects
    HRESULT hrCo = CoInitializeEx(NULL, COINIT_MULTITHREADED);
    bool comInitialized = SUCCEEDED(hrCo) || hrCo == RPC_E_CHANGED_MODE;

    if (!is_recording_) {
      std::cout << "[DesktopRecorder] Not recording, returning nil" << std::endl;
      result->Success(flutter::EncodableValue());
      if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
        CoUninitialize();
      }
      return;
    }

    StopRecording();

    // Check if file exists
    DWORD attrs = GetFileAttributesA(output_path_.c_str());
    if (attrs != INVALID_FILE_ATTRIBUTES && !(attrs & FILE_ATTRIBUTE_DIRECTORY)) {
      std::cout << "[DesktopRecorder] Returning path: " << output_path_ << std::endl;
      result->Success(flutter::EncodableValue(output_path_));
    } else {
      std::cout << "[DesktopRecorder] File not found: " << output_path_ << std::endl;
      result->Success(flutter::EncodableValue());
    }

    if (comInitialized && hrCo != RPC_E_CHANGED_MODE) {
      CoUninitialize();
    }
  }

 private:
  // Helper to enumerate video capture devices
  IMFActivate* FindVideoCaptureDevice(const std::string& device_id) {
    IMFActivate** ppDevices = NULL;
    UINT32 count = 0;

    IMFAttributes* pAttributes = NULL;
    HRESULT hr = MFCreateAttributes(&pAttributes, 1);
    if (FAILED(hr)) return nullptr;

    hr = pAttributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
    if (FAILED(hr)) {
      pAttributes->Release();
      return nullptr;
    }

    hr = MFEnumDeviceSources(pAttributes, &ppDevices, &count);
    pAttributes->Release();

    if (FAILED(hr) || count == 0) {
      return nullptr;
    }

    // If no specific device ID, return the first device
    IMFActivate* selectedDevice = ppDevices[0];
    selectedDevice->AddRef();

    // Clean up other devices
    for (UINT32 i = 0; i < count; i++) {
      if (i != 0) ppDevices[i]->Release();
    }
    CoTaskMemFree(ppDevices);

    return selectedDevice;
  }

  // Helper to enumerate audio capture devices
  IMFActivate* FindAudioCaptureDevice(const std::string& device_id) {
    IMFActivate** ppDevices = NULL;
    UINT32 count = 0;

    IMFAttributes* pAttributes = NULL;
    HRESULT hr = MFCreateAttributes(&pAttributes, 1);
    if (FAILED(hr)) return nullptr;

    hr = pAttributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_AUDCAP_GUID);
    if (FAILED(hr)) {
      pAttributes->Release();
      return nullptr;
    }

    hr = MFEnumDeviceSources(pAttributes, &ppDevices, &count);
    pAttributes->Release();

    if (FAILED(hr) || count == 0) {
      return nullptr;
    }

    // If no specific device ID, return the first device
    IMFActivate* selectedDevice = ppDevices[0];
    selectedDevice->AddRef();

    // Clean up other devices
    for (UINT32 i = 0; i < count; i++) {
      if (i != 0) ppDevices[i]->Release();
    }
    CoTaskMemFree(ppDevices);

    return selectedDevice;
  }

  // Capture thread function
  void CaptureThreadFunc() {
    CoInitializeEx(NULL, COINIT_MULTITHREADED);

    LONGLONG video_timestamp = 0;
    LONGLONG audio_timestamp = 0;
    int frame_count = 0;
    int audio_count = 0;
    int error_count = 0;

    std::cout << "[CaptureThread] Started capture thread (video";
    if (audio_reader_) std::cout << " + audio";
    std::cout << ")" << std::endl;

    while (is_recording_) {
      // Capture video frame
      if (!source_reader_) {
        std::cerr << "[CaptureThread] Video source reader is null!" << std::endl;
        break;
      }

      IMFSample* pVideoSample = NULL;
      DWORD streamIndex = 0;
      DWORD flags = 0;
      LONGLONG llTimeStamp = 0;

      HRESULT hr = source_reader_->ReadSample(
          (DWORD)MF_SOURCE_READER_FIRST_VIDEO_STREAM,
          0,
          &streamIndex,
          &flags,
          &llTimeStamp,
          &pVideoSample);

      if (FAILED(hr)) {
        std::cerr << "[CaptureThread] Video ReadSample failed: 0x" << std::hex << hr << std::dec << std::endl;
        error_count++;
        if (error_count > 10) break;
        continue;
      }

      if (flags & MF_SOURCE_READERF_ENDOFSTREAM) {
        std::cout << "[CaptureThread] Video end of stream" << std::endl;
        break;
      }

      if (pVideoSample && sink_writer_) {
        // Use device timestamps to keep playback speed consistent
        LONGLONG sampleTime = (llTimeStamp > 0) ? llTimeStamp : video_timestamp;
        LONGLONG sampleDuration = 0;
        if (FAILED(pVideoSample->GetSampleDuration(&sampleDuration)) || sampleDuration <= 0) {
          sampleDuration = frame_duration_;
          pVideoSample->SetSampleDuration(sampleDuration);
        }
        pVideoSample->SetSampleTime(sampleTime);

        hr = sink_writer_->WriteSample(video_stream_index_, pVideoSample);
        if (FAILED(hr)) {
          std::cerr << "[CaptureThread] Video WriteSample failed: 0x" << std::hex << hr << std::dec << std::endl;
          error_count++;
        } else {
          frame_count++;
          if (frame_count % 30 == 0) {  // Log every second
            std::cout << "[CaptureThread] Captured " << frame_count << " video frames";
            if (audio_reader_) std::cout << ", " << audio_count << " audio samples";
            std::cout << std::endl;
          }
        }

        video_timestamp = sampleTime + sampleDuration;
        pVideoSample->Release();
      }

      // Capture multiple audio samples (audio runs faster than video)
      if (audio_reader_ && sink_writer_) {
        // Read all available audio samples (typically 5-10 samples per video frame)
        for (int i = 0; i < 10 && is_recording_; i++) {
          IMFSample* pAudioSample = NULL;
          LONGLONG audioSampleTime = 0;
          LONGLONG audioDuration = 0;
          hr = audio_reader_->ReadSample(
              (DWORD)MF_SOURCE_READER_FIRST_AUDIO_STREAM,
              0,
              &streamIndex,
              &flags,
              &audioSampleTime,
              &pAudioSample);

          if (FAILED(hr) || !pAudioSample) {
            break; // No more audio samples available right now
          }

          if (flags & MF_SOURCE_READERF_ENDOFSTREAM) {
            if (pAudioSample) pAudioSample->Release();
            break;
          }

          // Set timestamp
          if (FAILED(pAudioSample->GetSampleDuration(&audioDuration)) || audioDuration <= 0) {
            // Default to ~10ms for 44.1kHz
            audioDuration = 10000000 / 100;
            pAudioSample->SetSampleDuration(audioDuration);
          }
          if (audioSampleTime <= 0) {
            audioSampleTime = audio_timestamp;
          }
          pAudioSample->SetSampleTime(audioSampleTime);
          audio_timestamp = audioSampleTime + audioDuration;

          hr = sink_writer_->WriteSample(audio_stream_index_, pAudioSample);
          if (SUCCEEDED(hr)) {
            audio_count++;
          }
          pAudioSample->Release();
        }
      }
    }

    CoUninitialize();
    std::cout << "[CaptureThread] Capture thread finished. Video frames: " << frame_count;
    if (audio_reader_) std::cout << ", Audio samples: " << audio_count;
    std::cout << ", Errors: " << error_count << std::endl;
  }

  std::atomic<bool> is_recording_;
  bool mf_initialized_;
  std::string output_path_;
  IMFSinkWriter* sink_writer_ = nullptr;
  IMFSourceReader* source_reader_ = nullptr;
  IMFSourceReader* audio_reader_ = nullptr;
  DWORD video_stream_index_ = 0;
  DWORD audio_stream_index_ = 0;
  UINT32 video_width_ = 0;
  UINT32 video_height_ = 0;
  LONGLONG frame_duration_ = 10000000LL / 30; // default 30fps in 100ns units
  std::thread capture_thread_;
};

// DesktopRecorder public interface
DesktopRecorder::DesktopRecorder() : impl_(std::make_unique<Impl>()) {}

DesktopRecorder::~DesktopRecorder() = default;

void DesktopRecorder::StartRecording(
    const std::string& output_path,
    const std::string& video_device_id,
    const std::string& audio_device_id,
    int fps,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  impl_->StartRecording(output_path, video_device_id, audio_device_id, fps, std::move(result));
}

void DesktopRecorder::StopRecording(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  impl_->StopRecordingWithResult(std::move(result));
}
