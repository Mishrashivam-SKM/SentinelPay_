import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  String _pin = '';
  bool _error = false;
  String _savedPin = '';
  
  @override
  void initState() {
    super.initState();
    _loadPinAndAuthenticate();
  }
  
  Future<void> _loadPinAndAuthenticate() async {
    _savedPin = await _storage.read(key: 'user_pin') ?? '';
    final biometricsEnabled = await _storage.read(key: 'biometrics_enabled') == 'true';
    
    if (biometricsEnabled) {
      _authenticateWithBiometrics();
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock SentinelPay',
        biometricOnly: true,
      );
      if (authenticated && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Biometric auth failed: $e');
    }
  }
  
  void _onDigitPress(String digit) {
    setState(() {
      _error = false;
      if (_pin.length < 4) _pin += digit;
      if (_pin.length == 4) {
        _verifyPin();
      }
    });
  }
  
  void _onDeletePress() {
    setState(() {
      _error = false;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }
  
  void _verifyPin() {
    if (_pin == _savedPin) {
      context.go('/dashboard');
    } else {
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Enter PIN', style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                _error ? 'Incorrect PIN, try again' : 'Enter your 4-digit PIN to unlock',
                style: AppTypography.bodyLg.copyWith(
                  color: _error ? AppColors.error : AppColors.onSurfaceVariant
                ),
              ),
              const SizedBox(height: 48),
              
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isFilled ? AppColors.primary : AppColors.onSurfaceVariant,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 64),
              
              // Numpad
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return InkWell(
                        onTap: _authenticateWithBiometrics,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 32),
                        ),
                      );
                    }
                    if (index == 11) {
                      return InkWell(
                        onTap: _onDeletePress,
                        customBorder: const CircleBorder(),
                        child: Center(
                          child: Icon(Icons.backspace_outlined, color: AppColors.onSurface),
                        ),
                      );
                    }
                    final digit = index == 10 ? '0' : '${index + 1}';
                    return InkWell(
                      onTap: () => _onDigitPress(digit),
                      customBorder: const CircleBorder(),
                      child: Center(
                        child: Text(digit, style: AppTypography.headlineLg),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
