import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class Otp3View extends StatefulWidget {
  const Otp3View({super.key});

  @override
  State<Otp3View> createState() => _Otp3ViewState();
}

class _Otp3ViewState extends State<Otp3View> {
  @override
  void initState() {
    super.initState();
    kodGonder();
  }

  final pinController = TextEditingController();
  String? errorMessage;
  late String dbpin;

  bool enabledPinput = true;
  bool circular = false;
  bool enabledButton = false;

  // kodGonder fonksiyonunda ekleyin:
  Future<void> kodGonder() async {
    setState(() {
      circular = true;
      enabledButton = false;
      enabledPinput = false;
    });
    await Future.delayed(Duration(seconds: 3));

    // Simüle edilmiş backend'den gelen kod
    dbpin = '1234'; // ← Bunu ekleyin

    setState(() {
      circular = false;
      enabledButton = true;
      enabledPinput = true;
    });
  }

  void customValidateAndContinue() {
    final pin = pinController.text;
    // Manuel validasyon
    if (pin.isEmpty) {
      scaffoldMessenger('PIN giriniz');
      return;
    }

    if (pin.length < 4) {
      scaffoldMessenger('PIN 4 haneli olmalı');
      return;
    }
    scaffoldMessenger('Doğru PIN, devam ediliyor...');
  }

  String? validatePin(String? pin) {
    // Sadece dbpin kontrolü, detaylı mesajlar customValidateAndContinue'da
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
                    'Aşşağıdaki adrese 4 haneli kod gönderildi\n example@gmail.com',
                  ),
            Text(errorMessage ?? '', style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            Pinput(
              // Kontrolcü
              controller: pinController,
              validator: validatePin,
              errorBuilder: (errorText, pin) {
                // ↓ Buraya gelir ve gösterilir
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
              // Tema ayarları
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
            ElevatedButton(onPressed: () {}, child: Text('Kodu Tekrar Gönder')),
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
    color: const Color.fromARGB(255, 65, 48, 48), // Çok açık gri arka plan
    border: Border.all(color: Colors.grey[300]!), // Soluk kenarlık
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
    color: Colors.grey[200], // GRİ ARKA PLAN
    borderRadius: BorderRadius.circular(20),
    // border: Border.all(color: Colors.grey[400]!), // İsteğe bağlı kenarlık
  ),
);

// Odaklanmış tema - bir şey girilirken ki hal (BEYAZ)
final focusedPinTheme = defaultPinTheme.copyDecorationWith(
  color: Colors.grey[200], // ARKA PLAN
  border: Border.all(color: Colors.blue, width: 2),
  borderRadius: BorderRadius.circular(20),
);

// Gönderilmiş tema - değer girildikten sonra (istediğiniz renk)
final submittedPinTheme = defaultPinTheme.copyWith(
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[600], // Girilmiş metin rengi
    fontWeight: FontWeight.w700,
  ),

  decoration: defaultPinTheme.decoration?.copyWith(
    color: Colors.grey[200], // Girilmiş kutular için açık gri
  ),
);

final errorPinTheme = defaultPinTheme.copyWith(
  textStyle: TextStyle(
    fontSize: 25,
    color: Colors.grey[600], // Aynı gri renk
    fontWeight: FontWeight.w700,
  ),
  decoration: defaultPinTheme.decoration?.copyWith(
    color: Colors.grey[200],
    border: Border.all(color: Colors.red),
  ),
);
