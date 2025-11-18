import 'package:flutter/material.dart';

class OtpScreen1 extends StatefulWidget {
  const OtpScreen1({super.key});

  @override
  State<OtpScreen1> createState() => _OtpScreen1State();
}

class _OtpScreen1State extends State<OtpScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OtpScreen1')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            ElevatedButton(onPressed: () {}, child: Text('OtpScreen1')),
            ElevatedButton(onPressed: () {}, child: Text('OtpScreen1')),
            ElevatedButton(onPressed: () {}, child: Text('OtpScreen1')),
            Text('OtpScreen1'),
          ],
        ),
      ),
    );
  }
}
