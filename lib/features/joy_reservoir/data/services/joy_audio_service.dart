import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// JoyAudioService manages offline audio playback for personal music anchors
/// in the Joy Reservoir. Ensures only one track plays at a time and provides
/// reactive status updates for play, pause, stop, and position seeking.
class JoyAudioService extends ChangeNotifier {
  static final JoyAudioService _instance = JoyAudioService._internal();
  factory JoyAudioService() => _instance;

  JoyAudioService._internal();

  AudioPlayer? _player;
  String? _currentJoyId;
  String? _currentFilePath;
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;

  void _ensurePlayer() {
    if (_player != null) return;
    try {
      _player = AudioPlayer();

      _stateSub = _player!.onPlayerStateChanged.listen((state) {
        _state = state;
        notifyListeners();
      });

      _durationSub = _player!.onDurationChanged.listen((duration) {
        _duration = duration;
        notifyListeners();
      });

      _positionSub = _player!.onPositionChanged.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      _completeSub = _player!.onPlayerComplete.listen((_) {
        _state = PlayerState.completed;
        _position = Duration.zero;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('[JoyAudioService] _ensurePlayer error: $e');
    }
  }

  // Getters
  String? get currentJoyId => _currentJoyId;
  String? get currentFilePath => _currentFilePath;
  PlayerState get state => _state;
  Duration get position => _position;
  Duration get duration => _duration;

  bool isPlaying(String joyId) =>
      _currentJoyId == joyId && _state == PlayerState.playing;

  bool isPaused(String joyId) =>
      _currentJoyId == joyId && _state == PlayerState.paused;

  bool isActive(String joyId) => _currentJoyId == joyId;

  /// Plays or resumes local audio playback
  Future<void> playLocal({
    required String joyId,
    required String filePath,
  }) async {
    try {
      _ensurePlayer();

      // If resuming same paused track
      if (_currentJoyId == joyId && _state == PlayerState.paused) {
        await _player!.resume();
        return;
      }

      // If switching track or starting fresh
      await _player!.stop();
      _currentJoyId = joyId;
      _currentFilePath = filePath;
      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();

      if (kIsWeb) {
        // On web fallback to UrlSource or BytesSource if URL
        if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
          await _player!.play(UrlSource(filePath));
        } else {
          await _player!.play(DeviceFileSource(filePath));
        }
      } else {
        final file = File(filePath);
        if (await file.exists()) {
          await _player!.play(DeviceFileSource(filePath));
        } else if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
          await _player!.play(UrlSource(filePath));
        } else {
          debugPrint('[JoyAudioService] Audio file not found at $filePath');
        }
      }
    } catch (e) {
      debugPrint('[JoyAudioService] playLocal error: $e');
    }
  }

  /// Pauses currently playing track
  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('[JoyAudioService] pause error: $e');
    }
  }

  /// Resumes playback of currently active track
  Future<void> resume() async {
    try {
      await _player?.resume();
    } catch (e) {
      debugPrint('[JoyAudioService] resume error: $e');
    }
  }

  /// Stops playback and resets playhead
  Future<void> stop() async {
    try {
      await _player?.stop();
      _currentJoyId = null;
      _position = Duration.zero;
      _state = PlayerState.stopped;
      notifyListeners();
    } catch (e) {
      debugPrint('[JoyAudioService] stop error: $e');
    }
  }

  /// Seeks to a specific timestamp in the audio track
  Future<void> seek(Duration position) async {
    try {
      await _player?.seek(position);
    } catch (e) {
      debugPrint('[JoyAudioService] seek error: $e');
    }
  }

  /// Formats duration to readable mm:ss format
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _player?.dispose();
    _player = null;
    super.dispose();
  }
}
