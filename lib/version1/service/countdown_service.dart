// countdown_service.dart
import 'dart:async';
import 'dart:ui';

class CountdownService {
  int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  final int initialSeconds;
  final Function(int)? onTick;
  final VoidCallback? onComplete;

  CountdownService({required this.initialSeconds, this.onTick, this.onComplete})
    : _remainingSeconds = initialSeconds;

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick?.call(_remainingSeconds);
      } else {
        stop();
        onComplete?.call();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
  }

  void resume() {
    if (_remainingSeconds > 0 && !_isRunning) {
      start();
    }
  }

  void reset() {
    _timer?.cancel();
    _remainingSeconds = initialSeconds;
    _isRunning = false;
    onTick?.call(_remainingSeconds);
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
  }

  void dispose() {
    _timer?.cancel();
  }

  String formatTime() {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
