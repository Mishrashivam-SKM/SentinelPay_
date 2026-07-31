// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';


class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _error = false;
  
  void _onDigitPress(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      if (!_isConfirming) {
        if (_pin.length < 4) _pin += digit;
        if (_pin.length == 4) {
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _isConfirming = true;
            });
          });
        }
      } else {
        if (_confirmPin.length < 4) _confirmPin += digit;
        if (_confirmPin.length == 4) {
          _verifyAndSave();
        }
      }
    });
  }
  
  void _onDeletePress() {
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (_isConfirming && _confirmPin.isEmpty) {
        // Go back to first step
        _isConfirming = false;
        _pin = '';
      }
    });
  }
  
  Future<void> _verifyAndSave() async {
    if (_pin == _confirmPin) {
      HapticFeedback.heavyImpact();
      
      final random = Random.secure();
      final salt = base64UrlEncode(List<int>.generate(16, (i) => random.nextInt(256)));
      final bytes = utf8.encode(_pin + salt);
      final digest = sha256.convert(bytes);
      
      await _storage.write(key: 'user_pin_hash', value: digest.toString());
      await _storage.write(key: 'user_pin_salt', value: salt);
      await _storage.delete(key: 'user_pin'); // Cleanup old plaintext
      
      await _storage.write(key: 'is_onboarded', value: 'true');
      
      // Optional: Check if biometrics are available and ask to enable
      try {
        bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        bool isDeviceSupported = await _localAuth.isDeviceSupported();
        
        if (canCheckBiometrics && isDeviceSupported) {
          await _storage.write(key: 'biometrics_enabled', value: 'true');
        }
      } catch (e) {
        debugPrint('Biometrics not available on emulator/device');
      }
      
      if (mounted) context.go('/dashboard');
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentInput = _isConfirming ? _confirmPin : _pin;
    final title = _isConfirming ? 'Confirm your PIN' : 'Set a 4-digit PIN';
    final subtitle = _isConfirming 
        ? 'Re-enter your PIN to confirm' 
        : 'This will secure your SentinelPay AI';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(title, style: AppTypography.headlineLg),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTypography.bodyLg.copyWith(
                  color: _error ? AppColors.error : AppColors.onSurfaceVariant
                ),
              ),
              const SizedBox(height: 48),
              
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < currentInput.length;
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
                    if (index == 9) return const SizedBox(); // Empty bottom-left
                    if (index == 11) {
                      return Semantics(
                        label: 'Delete last digit',
                        button: true,
                        child: InkWell(
                          onTap: _onDeletePress,
                          borderRadius: BorderRadius.circular(40),
                          child: Center(
                            child: Icon(Icons.backspace_outlined, color: AppColors.onSurface),
                          ),
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
