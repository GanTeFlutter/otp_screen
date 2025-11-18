import 'package:flutter/material.dart';
import 'package:flutter_opt/version1/service/countdown_service.dart';
import 'package:pinput/pinput.dart';

class Otp4View extends StatefulWidget {
  const Otp4View({super.key});

  @override
  State<Otp4View> createState() => _Otp4ViewState();
}

class _Otp4ViewState extends State<Otp4View> {
  final pinController = TextEditingController();
  String? errorMessage;
  late String dbpin;

  bool enabledPinput = true;
  bool circular = false;
  bool enabledButton = false;

  CountdownService? _countdownService;

  @override
  void initState() {
    super.initState();
    kodGonder();
  }

  @override
  void dispose() {
    _countdownService?.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> kodGonder() async {
    setState(() {
      circular = true;
      enabledButton = false;
      enabledPinput = false;
      _countdownService?.dispose();
      _countdownService = null;
    });

    await Future.delayed(Duration(seconds: 3));

    // Simüle edilmiş backend'den gelen kod
    dbpin = '1234';

    setState(() {
      circular = false;
      enabledButton = true;
      enabledPinput = true;
    });

    // Countdown'u başlat
    _countdownService = CountdownService(
      initialSeconds: 30, // 2 dakika
      onTick: (remainingSeconds) {
        setState(() {});
      },
      onComplete: () {
        setState(() {
          enabledPinput = false;
          enabledButton = false;
        });
        scaffoldMessenger('Süre doldu! Kodu tekrar gönderin.');
      },
    );
    _countdownService!.start();
  }

  void customValidateAndContinue() {
    final pin = pinController.text;

    if (pin.isEmpty) {
      scaffoldMessenger('PIN giriniz');
      return;
    }

    if (pin.length < 4) {
      scaffoldMessenger('PIN 4 haneli olmalı');
      return;
    }

    if (pin != dbpin) {
      scaffoldMessenger('Yanlış PIN');
      return;
    }

    scaffoldMessenger('Doğru PIN, devam ediliyor...');
    // Başarılı giriş sonrası countdown'u durdur
    _countdownService?.stop();
  }

  String? validatePin(String? pin) {
    if (pin != null && pin.length == 4 && pin != dbpin) {
      return 'Yanlış PIN';
    }
    return null;
  }

  void scaffoldMessenger(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            circular
                ? CircularProgressIndicator()
                : Text(
                    textAlign: TextAlign.center,
                    'Aşağıdaki adrese 4 haneli kod gönderildi\nexample@gmail.com',
                  ),

            // Countdown Timer
            if (_countdownService != null && !circular)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Kalan süre: ${_countdownService!.formatTime()}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _countdownService!.remainingSeconds <= 30
                        ? Colors.red
                        : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Text(errorMessage ?? '', style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),

            Pinput(
              controller: pinController,
              validator: validatePin,
              errorBuilder: (errorText, pin) {
                return Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    errorText ?? '',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              onCompleted: (pin) => print(pin),
              focusNode: FocusNode(),
              enabled: enabledPinput,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              errorPinTheme: errorPinTheme,
              disabledPinTheme: disabledPinTheme,
            ),

            SizedBox(height: 10),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: enabledButton ? customValidateAndContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: enabledButton ? Colors.blue : Colors.grey,
                foregroundColor: enabledButton ? Colors.white : Colors.white70,
              ),
              child: Text('Continue'),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed:
                  (_countdownService?.remainingSeconds == 0 ||
                      _countdownService == null)
                  ? kodGonder
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (_countdownService?.remainingSeconds == 0 ||
                        _countdownService == null)
                    ? Colors.orange
                    : Colors.grey,
              ),
              child: Text('Kodu Tekrar Gönder'),
            ),
          ],
        ),
      ),
    );
  }
}

final disabledPinTheme = defaultPinTheme.copyWith(
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[800],
    fontWeight: FontWeight.w700,
  ),
  decoration: defaultPinTheme.decoration?.copyWith(
    color: const Color.fromARGB(255, 124, 121, 121),
    border: Border.all(color: Colors.grey[300]!),
  ),
);

final defaultPinTheme = PinTheme(
  width: 56,
  height: 56,
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[800],
    fontWeight: FontWeight.w900,
  ),
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(20),
  ),
);

final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  color: Colors.grey[200],
  border: Border.all(color: Colors.blue, width: 2),
  borderRadius: BorderRadius.circular(20),
);

final submittedPinTheme = defaultPinTheme.copyWith(
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[600],
    fontWeight: FontWeight.w700,
  ),
  decoration: defaultPinTheme.decoration?.copyWith(color: Colors.grey[200]),
);

final errorPinTheme = defaultPinTheme.copyWith(
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[600],
    fontWeight: FontWeight.w700,
  ),
  decoration: defaultPinTheme.decoration?.copyWith(
    color: Colors.grey[200],
    border: Border.all(color: Colors.red),
  ),
);
