import 'package:flutter/material.dart';
import 'package:flutter_opt/version1/service/countdown_service.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late CountdownService _countdownService;

  @override
  void initState() {
    super.initState();
    _countdownService = CountdownService(
      initialSeconds: 120,
      onTick: (remainingSeconds) {
        setState(() {});
      },
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geri sayım tamamlandı! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
    _countdownService.start();
  }

  @override
  void dispose() {
    _countdownService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geri Sayım Uygulaması'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Geri Sayım',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _countdownService.formatTime(),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: _countdownService.remainingSeconds <= 10
                      ? Colors.red
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        if (_countdownService.isRunning) {
                          _countdownService.pause();
                        } else {
                          _countdownService.resume();
                        }
                      });
                    },
                    icon: Icon(
                      _countdownService.isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _countdownService.isRunning ? 'Duraklat' : 'Devam',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _countdownService.isRunning
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
                        _countdownService.reset();
                        _countdownService.start();
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
