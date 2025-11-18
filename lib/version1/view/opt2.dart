import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AdvancedOtpScreen extends StatefulWidget {
  const AdvancedOtpScreen({super.key});

  @override
  State<AdvancedOtpScreen> createState() => _AdvancedOtpScreenState();
}

class _AdvancedOtpScreenState extends State<AdvancedOtpScreen>
    with TickerProviderStateMixin {
  static const int _otpLength = 4;
  static const Duration _animDuration = Duration(milliseconds: 300);
  
  final _controllers = List.generate(_otpLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  final _fieldKeys = List.generate(_otpLength, (_) => GlobalKey());
  
  late final AnimationController _shakeController;
  late final AnimationController _successController;
  late final Animation<double> _shakeAnimation;
  late final Animation<double> _successAnimation;
  
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSuccess = false;
  Timer? _resendTimer;
  int _resendSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startResendTimer();
    
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _initAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _successAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeInOut,
    );
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 30;
      _canResend = false;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
    _resendTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOtpChange(String value, int index) {
    setState(() {
      _hasError = false;
    });
    
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // Auto-submit when all fields are filled
        if (_controllers.every((c) => c.text.isNotEmpty)) {
          _handleSubmit();
        }
      }
    }
  }

  void _handleKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && 
        event.logicalKey == LogicalKeyboardKey.backspace && 
        _controllers[index].text.isEmpty && 
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handlePaste(String value) {
    if (value.length >= _otpLength) {
      for (int i = 0; i < _otpLength; i++) {
        if (i < value.length && RegExp(r'^\d$').hasMatch(value[i])) {
          _controllers[i].text = value[i];
        }
      }
      _focusNodes.last.unfocus();
      if (_controllers.every((c) => c.text.isNotEmpty)) {
        _handleSubmit();
      }
    }
  }

  Future<void> _handleSubmit() async {
    final isEmpty = _controllers.any((c) => c.text.isEmpty);
    
    if (isEmpty) {
      setState(() => _hasError = true);
      await _shakeController.forward();
      _shakeController.reset();
      
      HapticFeedback.mediumImpact();
      
      _showSnackBar('Lütfen tüm alanları doldurun', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    final code = _controllers.map((c) => c.text).join();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate success (you would check actual response here)
    bool isValidCode = code == '1234'; // Example validation
    
    setState(() => _isLoading = false);
    
    if (isValidCode) {
      setState(() => _isSuccess = true);
      await _successController.forward();
      HapticFeedback.lightImpact();
      
      _showSnackBar('Doğrulama başarılı!', isError: false);
      
      // Navigate to next screen
      // Navigator.pushReplacement(context, ...);
    } else {
      setState(() => _hasError = true);
      await _shakeController.forward();
      _shakeController.reset();
      
      HapticFeedback.heavyImpact();
      _clearFields();
      
      _showSnackBar('Geçersiz kod. Tekrar deneyin.', isError: true);
    }
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {
      _hasError = false;
      _isSuccess = false;
    });
  }

  void _resendOtp() {
    if (!_canResend) return;
    
    HapticFeedback.selectionClick();
    _clearFields();
    _startResendTimer();
    _showSnackBar('Yeni kod gönderildi', isError: false);
    
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Icon with animation
              AnimatedBuilder(
                animation: _successAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isSuccess ? _successAnimation.value * 1.2 : 1.0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isSuccess
                              ? [Colors.green.shade400, Colors.green.shade600]
                              : [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isSuccess ? Colors.green : theme.primaryColor)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSuccess ? Icons.check : Icons.lock_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Doğrulama Kodu',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                '+90 555 123 4567 numarasına\ngönderilen kodu giriniz',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OTP Fields
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _hasError ? _shakeAnimation.value * ((_shakeController.value * 2 - 1)) : 0,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _otpLength,
                        (index) => AnimatedContainer(
                          duration: _animDuration,
                          margin: EdgeInsets.symmetric(horizontal: index == 1 || index == 2 ? 8 : 4),
                          child: _buildOtpField(index, isDark),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Resend Timer
              AnimatedSwitcher(
                duration: _animDuration,
                child: _canResend
                    ? TextButton.icon(
                        onPressed: _resendOtp,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Kodu Tekrar Gönder'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tekrar gönder ($_resendSeconds saniye)',
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
              
              const Spacer(flex: 2),
              
              // Submit Button
              AnimatedContainer(
                duration: _animDuration,
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuccess 
                        ? Colors.green 
                        : _hasError 
                            ? Colors.red 
                            : theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: _isLoading ? 0 : 4,
                    shadowColor: theme.primaryColor.withOpacity(0.4),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            _isSuccess ? 'Başarılı!' : 'Doğrula',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index, bool isDark) {
    final isActive = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    
    return SizedBox(
      key: _fieldKeys[index],
      width: 65,
      height: 70,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _handleKeyEvent(event, index),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          maxLength: 1,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _isSuccess 
                ? Colors.green 
                : _hasError 
                    ? Colors.red 
                    : isDark 
                        ? Colors.white 
                        : Colors.black87,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            // Handle paste
            if (value.length > 1) {
              _handlePaste(value);
            } else {
              _handleOtpChange(value, index);
            }
          },
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isDark
                ? (isActive 
                    ? Colors.grey.shade800 
                    : hasValue 
                        ? Colors.grey.shade800 
                        : const Color.fromARGB(255, 153, 153, 153))
                : (isActive 
                    ? Colors.white 
                    : hasValue 
                        ? Colors.white 
                        : Colors.grey.shade100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _getBorderColor(isActive, hasValue, isDark),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _getBorderColor(false, hasValue, isDark),
                width: hasValue ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _getBorderColor(true, hasValue, isDark),
                width: 2.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool isActive, bool hasValue, bool isDark) {
    if (_isSuccess) return Colors.green;
    if (_hasError) return Colors.red.shade400;
    if (isActive) return Theme.of(context).primaryColor;
    if (hasValue) return Theme.of(context).primaryColor.withOpacity(0.5);
    return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  }
}

// Usage Example
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced OTP Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        useMaterial3: true,
      ),
      home: const AdvancedOtpScreen(),
    );
  }
}