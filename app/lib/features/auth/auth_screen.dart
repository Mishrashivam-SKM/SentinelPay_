// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
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
  String _savedPinHash = '';
  String _savedPinSalt = '';
  
  // Brute force protection
  int _attempts = 0;
  DateTime? _lockoutUntil;
  Timer? _lockoutTimer;
  
  @override
  void initState() {
    super.initState();
    _loadPinAndAuthenticate();
  }
  
  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadPinAndAuthenticate() async {
    _savedPinHash = await _storage.read(key: 'user_pin_hash') ?? '';
    _savedPinSalt = await _storage.read(key: 'user_pin_salt') ?? '';
    
    // Legacy migration check removed for strict security.
    // If a user has an old plaintext pin, they will be forced to re-onboard or reset.

    final attemptsStr = await _storage.read(key: 'pin_attempts') ?? '0';
    _attempts = int.tryParse(attemptsStr) ?? 0;
    
    final lockoutStr = await _storage.read(key: 'pin_lockout_until');
    if (lockoutStr != null) {
      _lockoutUntil = DateTime.tryParse(lockoutStr);
      _checkLockout();
    }
    final biometricsEnabled = await _storage.read(key: 'biometrics_enabled') == 'true';
    
    if (biometricsEnabled) {
      _authenticateWithBiometrics();
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock SentinelPay',
        // ignore: deprecated_member_use
        biometricOnly: true,
      );
      if (authenticated && mounted) {
        HapticFeedback.heavyImpact();
        context.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Biometric auth failed: $e');
    }
  }
  
  void _checkLockout() async {
    if (_lockoutUntil != null) {
      final now = DateTime.now();
      // Time-travel check: if now is inexplicably far in the past compared to last attempt
      final lastAttemptStr = await _storage.read(key: 'last_attempt_time');
      if (lastAttemptStr != null) {
        final lastAttempt = DateTime.tryParse(lastAttemptStr);
        if (lastAttempt != null && now.isBefore(lastAttempt)) {
           // User rewound the clock. Extend lockout heavily.
           _lockoutUntil = lastAttempt.add(const Duration(minutes: 30));
           await _storage.write(key: 'pin_lockout_until', value: _lockoutUntil!.toIso8601String());
        }
      }

      if (now.isBefore(_lockoutUntil!)) {
        setState(() => _error = true);
        final duration = _lockoutUntil!.difference(now);
        _lockoutTimer = Timer(duration, () {
          if (mounted) setState(() => _error = false);
        });
      } else {
        _lockoutUntil = null;
        _storage.delete(key: 'pin_lockout_until');
      }
    }
  }

  void _onDigitPress(String digit) {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      HapticFeedback.heavyImpact();
      return; // Locked out
    }
    
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      if (_pin.length < 4) _pin += digit;
      if (_pin.length == 4) {
        _verifyPin();
      }
    });
  }
  
  void _onDeletePress() {
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }
  
  Future<void> _verifyPin() async {
    bool isMatch = false;
    await _storage.write(key: 'last_attempt_time', value: DateTime.now().toIso8601String());
    
    if (_savedPinSalt.isNotEmpty) {
      final bytes = utf8.encode(_pin + _savedPinSalt);
      final digest = sha256.convert(bytes);
      isMatch = digest.toString() == _savedPinHash;
    } else {
      // Strict matching. If no salt exists, PIN wasn't set up securely.
      // Do not allow plaintext fallback.
      isMatch = false; 
    }

    if (isMatch) {
      HapticFeedback.heavyImpact();
      _attempts = 0;
      await _storage.write(key: 'pin_attempts', value: '0');
      if (mounted) context.go('/dashboard');
    } else {
      HapticFeedback.heavyImpact();
      _attempts++;
      await _storage.write(key: 'pin_attempts', value: _attempts.toString());
      
      if (_attempts >= 5) {
        // Exponential backoff: 5 attempts = 30s, 6 = 1m, 7 = 2m, etc.
        final lockoutSeconds = 15 * (1 << (_attempts - 4));
        _lockoutUntil = DateTime.now().add(Duration(seconds: lockoutSeconds));
        await _storage.write(key: 'pin_lockout_until', value: _lockoutUntil!.toIso8601String());
        _checkLockout();
      }
      
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
                _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)
                    ? 'Locked out. Try again in ${_lockoutUntil!.difference(DateTime.now()).inSeconds}s'
                    : _error 
                        ? 'Incorrect PIN, try again' 
                        : 'Enter your 4-digit PIN to unlock',
                style: AppTypography.bodyLg.copyWith(
                  color: _error || (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!))
                      ? AppColors.error 
                      : AppColors.onSurfaceVariant
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
                      return Semantics(
                        label: 'Authenticate with Fingerprint or Face ID',
                        button: true,
                        child: InkWell(
                          onTap: _authenticateWithBiometrics,
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.fingerprint_rounded, size: 32, color: AppColors.primary),
                          ),
                        ),
                      );
                    }
                    if (index == 11) {
                      return Semantics(
                        label: 'Delete last digit',
                        button: true,
                        child: InkWell(
                          onTap: _onDeletePress,
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.backspace_rounded, size: 28, color: AppColors.onSurfaceVariant),
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
