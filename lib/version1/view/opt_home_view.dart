import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptHomeView extends StatefulWidget {
  const OptHomeView({super.key});

  @override
  State<OptHomeView> createState() => _OptHomeViewState();
}

class _OptHomeViewState extends State<OptHomeView> {
  late final List<TextEditingController> controllers;

  void initControllers() {
    controllers = List.generate(4, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  bool textfieldBorder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OptHomeView')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                spacing: 20,
                children: List.generate(
                  controllers.length,
                  (index) => Expanded(
                    child: TextField(
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty &&
                            index < controllers.length - 1) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      controller: controllers[index],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? 3
                                : 1,
                            color:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? Colors.red
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? 3
                                : 1,
                            color:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? Colors.red
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? 3
                                : 1,
                            color:
                                textfieldBorder &&
                                    controllers[index].text.isEmpty
                                ? Colors.red
                                : Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (controllers.any((c) => c.text.isEmpty)) {
                  textfieldBorder = true;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen tüm alanları doldurun'),
                    ),
                  );
                  return;
                }

                String code = controllers.map((c) => c.text).join();
              },
              child: Text('Send Message'),
            ),
          ],
        ),
      ),
    );
  }
}
