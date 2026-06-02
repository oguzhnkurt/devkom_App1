import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecordingService {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordingPath;
  DateTime? _startTime;
  bool _isInitialized = false;

  bool get isRecording => _isRecording;
  int get recordingDuration {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  /// Initialize the recorder
  Future<void> _initRecorder() async {
    if (_isInitialized) return;

    try {
      await _audioRecorder.openRecorder();
      _isInitialized = true;
      print('Voice recorder initialized');
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start voice recording
  Future<bool> startRecording() async {
    try {
      // Initialize if needed
      await _initRecorder();

      // Check and request permission
      if (!await requestPermission()) {
        print('Microphone permission denied');
        return false;
      }

      // Check if already recording
      if (_isRecording) {
        print('Already recording');
        return false;
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      _recordingPath = '${directory.path}/$fileName';

      // Start recording
      await _audioRecorder.startRecorder(
        toFile: _recordingPath!,
        codec: Codec.aacADTS,
      );

      _isRecording = true;
      _startTime = DateTime.now();
      print('Recording started: $_recordingPath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      return false;
    }
  }

  /// Stop voice recording
  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        print('Not currently recording');
        return null;
      }

      final path = await _audioRecorder.stopRecorder();
      _isRecording = false;
      _startTime = null;

      print('Recording stopped: $path');
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      _startTime = null;
      return null;
    }
  }

  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stopRecorder();
        _isRecording = false;
        _startTime = null;
        _recordingPath = null;
      }
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Dispose the recorder
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await _audioRecorder.closeRecorder();
        _isInitialized = false;
      }
    } catch (e) {
      print('Error disposing recorder: $e');
    }
  }
}
