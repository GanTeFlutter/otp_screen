// countdown_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_opt/extension/show_sncakbar.dart';
import 'package:flutter_opt/version1/service/countdown_service.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  CountdownService? _countdownService;

  void _initializeCountdown() {
    _countdownService = CountdownService(
      initialSeconds: 10,
      onTick: (remainingSeconds) {
        setState(() {});
      },
      onComplete: () {
        context.showSnackBarExt('Geri sayım tamamlandı! 🎉', isError: false);
      },
    );
    _countdownService!.start();
  }

  @override
  void dispose() {
    _countdownService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _countdownService?.formatTime() ?? '02:00',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: (_countdownService?.remainingSeconds ?? 120) <= 10
                      ? Colors.red
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              if (_countdownService == null)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _initializeCountdown();
                    });
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_countdownService!.isRunning) {
                            _countdownService!.pause();
                          } else {
                            _countdownService!.resume();
                          }
                        });
                      },
                      icon: Icon(
                        _countdownService!.isRunning
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        _countdownService!.isRunning ? 'Duraklat' : 'Devam',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _countdownService!.isRunning
                            ? Colors.orange
                            : Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _countdownService!.reset();
                          _countdownService!.start();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Sıfırla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
