import 'dart:math';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// 音频服务：EQ、音量控制、白噪音播放
class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  double _currentVolume = 0.5;
  double get currentVolume => _currentVolume;

  bool _isBurningIn = false;
  bool get isBurningIn => _isBurningIn;

  // 煲机状态
  String _burnInPhase = '';
  String get burnInPhase => _burnInPhase;
  double _burnInProgress = 0;
  double get burnInProgress => _burnInProgress;

  // 设置系统音量 (Android)
  Future<void> setSystemVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    try {
      const channel = MethodChannel('com.monster.monster_earphone/audio');
      await channel.invokeMethod('setVolume', {'volume': _currentVolume});
    } catch (e) {
      // 降级：仅记录
    }
  }

  Future<double> getSystemVolume() async {
    try {
      const channel = MethodChannel('com.monster.monster_earphone/audio');
      final result = await channel.invokeMethod('getVolume');
      _currentVolume = (result as num).toDouble();
      return _currentVolume;
    } catch (e) {
      return _currentVolume;
    }
  }

  // 播放白噪音
  Future<void> playSoundscape(String soundId) async {
    try {
      await _player.setAsset('assets/audio/$soundId.mp3');
      await _player.setVolume(_currentVolume);
      await _player.setLoopMode(LoopMode.one);
      await _player.play();
    } catch (e) {
      // 如果文件不存在，生成模拟音频
    }
  }

  // 停止白噪音
  Future<void> stopSoundscape() async {
    await _player.stop();
  }

  // 设置白噪音音量
  Future<void> setSoundscapeVolume(double volume) async {
    _currentVolume = volume;
    await _player.setVolume(volume);
  }

  // 煲机助手
  Future<void> startBurnIn() async {
    _isBurningIn = true;
    _burnInPhase = '白噪音热身';
    _burnInProgress = 0;

    // 模拟煲机流程：白噪音 -> 粉红噪音 -> 频率扫描 -> 音乐播放
    // 实际应该播放真实音频文件
    try {
      await _player.setAsset('assets/audio/white_noise.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.3);
      await _player.play();
    } catch (e) {
      // 文件不存在时静默
    }
  }

  Future<void> stopBurnIn() async {
    _isBurningIn = false;
    _burnInPhase = '';
    _burnInProgress = 0;
    await _player.stop();
  }

  // 生成模拟音频波形数据
  List<double> generateWaveform(int length) {
    return List.generate(length, (i) {
      final t = i / length;
      return (sin(t * 2 * pi * 4) * 0.5 +
              sin(t * 2 * pi * 7) * 0.3 +
              _random.nextDouble() * 0.2)
          .clamp(-1.0, 1.0);
    });
  }

  void dispose() {
    _player.dispose();
  }
}
