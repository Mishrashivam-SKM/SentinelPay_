// coverage:ignore-file
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';

import 'dart:convert';
import '../../core/providers/risk_provider.dart';
import '../ml/ml_pipeline_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    // Artificial delay for splash animation
    await Future.delayed(const Duration(seconds: 2));
    
    // Train ML model on boot with historical data in a background isolate
    if (!mounted) return;
    final bi = ProviderScope.containerOf(context, listen: false).read(behaviourIntelligenceProvider);
    
    // Try to load serialized model from background task
    final modelJson = await _storage.read(key: 'bi_model_state');
    if (modelJson != null) {
      try {
        bi.loadFromMap(jsonDecode(modelJson));
      } catch (e) {
        final pipeline = MlPipelineService(bi);
        await pipeline.retrainOnLatest();
      }
    } else {
      final pipeline = MlPipelineService(bi);
      await pipeline.retrainOnLatest();
    }
    
    final isOnboarded = await _storage.read(key: 'is_onboarded');
    
    if (mounted) {
      if (isOnboarded == 'true') {
        context.go('/auth');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shield Logo with Glow
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppDecorations.aiGlowEmerald,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 4.seconds),
                  
                  Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: AppColors.primary,
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .then()
                  .shimmer(duration: 1200.ms, color: Colors.white54),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            Text(
              'SentinelPay',
              style: AppTypography.displayLg.copyWith(color: AppColors.onSurface),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            
            const SizedBox(height: 12),
            
            Text(
              'Your Personal UPI Safety Copilot',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
