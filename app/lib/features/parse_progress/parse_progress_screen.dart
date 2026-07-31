// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';
import '../sms_parser/sms_bootstrap_service.dart';

class ParseProgressScreen extends StatefulWidget {
  const ParseProgressScreen({super.key});

  @override
  State<ParseProgressScreen> createState() => _ParseProgressScreenState();
}

class _ParseProgressScreenState extends State<ParseProgressScreen> {
  final SmsBootstrapService _bootstrapService = SmsBootstrapService();
  double _progress = 0.0;
  String _statusMessage = 'Initializing Sentinel AI...';
  int _matchedCount = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startBootstrapping();
  }

  Future<void> _startBootstrapping() async {
    await _bootstrapService.bootstrapFromSmsHistory((processed, matched, total) {
      if (mounted) {
        setState(() {
          _progress = total == 0 ? 1.0 : processed / total;
          _matchedCount = matched;
          
          if (_progress < 0.5) {
            _statusMessage = 'Scanning transaction history...';
          } else if (_progress < 0.9) {
            _statusMessage = 'Found $matched payment messages...';
          } else {
            _statusMessage = 'Building your risk model...';
          }
        });
      }
    });

    if (mounted) {
      setState(() {
        _progress = 1.0;
        _statusMessage = 'Model trained. Ready.';
        _isComplete = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/parsed_review');
        }
      });
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
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppDecorations.aiGlow,
              ),
              child: CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 8.0,
                percent: _progress,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppColors.surfaceContainerHigh,
                linearGradient: AppDecorations.aiGradientReverse,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isComplete)
                      Icon(Icons.check_rounded, color: AppColors.primary, size: 48)
                    else
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: AppTypography.displayLg.copyWith(color: AppColors.onSurface),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            Text(
              _statusMessage,
              style: AppTypography.titleMd,
            ),
            
            if (_matchedCount > 0 && !_isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Extracting $_matchedCount secure data points',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
              
            const SizedBox(height: 64),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 16),
                const SizedBox(width: 8),
                Text(
                  'This data never leaves your device',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
