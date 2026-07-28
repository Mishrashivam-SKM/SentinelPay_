import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/utils/upi_parser.dart';
import '../../core/providers/risk_provider.dart';
import '../../core/data/database/transaction_dao.dart';
import '../../core/data/models/risk_assessment.dart';
import '../../core/data/models/parsed_transaction.dart';
import 'dart:async';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        setState(() => _isProcessing = true);
        
        final parser = UpiParser(code);
        
        // Non-payment QR detection (URL, text, etc)
        if (!parser.isValidUpiUri) {
          final engine = ref.read(riskFusionEngineProvider);
          // Manually create a block assessment for invalid QR
          final assessment = RiskAssessment(
            transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
            verdict: RiskVerdict.block,
            confidenceScore: 1.0,
            evidence: [
              EvidenceItem(
                key: 'invalid_qr',
                label: 'Format',
                detail: 'This is not a valid UPI payment code. It may link to a malicious website or app.',
                isPositive: false,
              )
            ],
            explanationTitle: 'Invalid Payment QR Code',
            explanationBody: 'Scanning this code will not initiate a secure UPI payment.',
          );
          
          if (mounted) {
            context.go('/analysis', extra: {
              'assessment': assessment,
              'upiUri': code,
            });
          }
          return;
        }

        // Live processing
        final engine = ref.read(riskFusionEngineProvider);
        final history = await TransactionDao().getAllTransactions();
        
        final assessment = engine.assessLiveIntent(
          parser.payeeVpa ?? 'Unknown',
          parser.payeeName ?? 'Unknown Entity',
          parser.amount ?? 0.0,
          history,
        );

        if (mounted) {
           // We pass both the assessment and the original URI so handoff can launch it
           context.go('/analysis', extra: {
             'assessment': assessment,
             'upiUri': code,
           });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
        title: Text(
          'SentinelPay',
          style: AppTypography.titleMd.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_rounded, color: AppColors.error, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Access Denied', 
                      style: AppTypography.titleMd.copyWith(color: AppColors.error)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SentinelPay needs your camera to scan UPI QR codes.', 
                      style: AppTypography.bodyLg,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      onPressed: () {
                        // We use permission_handler to open settings
                        openAppSettings();
                      },
                      child: const Text('Open Settings'),
                    )
                  ],
                ),
              );
            },
          ),
          
          // Custom Overlay
          _buildOverlay(),
          
          // Scanning UI Elements
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 48),
                Text('Scan QR Code', style: AppTypography.headlineLg),
                const SizedBox(height: 8),
                Text(
                  'Align code within the frame to pay',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ),
                
                const Spacer(),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(Icons.flashlight_on_outlined, () {
                      _scannerController.toggleTorch();
                    }),
                    const SizedBox(width: 24),
                    _buildActionButton(Icons.image_outlined, () {
                      // Select from gallery
                    }),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Manual Entry
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text('ENTER UPI ID MANUALLY', style: AppTypography.labelCaps),
                ),
                
                const SizedBox(height: 100), // Bottom nav padding
              ],
            ),
          ),
          
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text('Analyzing QR Context...', style: AppTypography.titleMd),
                  ],
                ),
              ),
            ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final scanAreaOffset = Offset(
          (constraints.maxWidth - scanAreaSize) / 2,
          (constraints.maxHeight - scanAreaSize) / 2 - 50,
        );
        
        return Stack(
          children: [
            // Darkened background with clear cutout
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 100), // Offset slightly up
                        width: scanAreaSize,
                        height: scanAreaSize,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Corner brackets
            Positioned(
              left: scanAreaOffset.dx,
              top: scanAreaOffset.dy,
              child: _buildCornerBracket(true, true),
            ),
            Positioned(
              right: scanAreaOffset.dx,
              top: scanAreaOffset.dy,
              child: _buildCornerBracket(false, true),
            ),
            Positioned(
              left: scanAreaOffset.dx,
              bottom: constraints.maxHeight - scanAreaOffset.dy - scanAreaSize,
              child: _buildCornerBracket(true, false),
            ),
            Positioned(
              right: scanAreaOffset.dx,
              bottom: constraints.maxHeight - scanAreaOffset.dy - scanAreaSize,
              child: _buildCornerBracket(false, false),
            ),
            
            // Animated scan line
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  left: scanAreaOffset.dx + 20,
                  top: scanAreaOffset.dy + 20 + (_animation.value * (scanAreaSize - 40)),
                  child: Container(
                    width: scanAreaSize - 40,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCornerBracket(bool isLeft, bool isTop) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          left: isLeft ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
          top: isTop ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primary, width: 3) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isLeft && isTop ? const Radius.circular(24) : Radius.zero,
          topRight: !isLeft && isTop ? const Radius.circular(24) : Radius.zero,
          bottomLeft: isLeft && !isTop ? const Radius.circular(24) : Radius.zero,
          bottomRight: !isLeft && !isTop ? const Radius.circular(24) : Radius.zero,
        ),
      ),
    );
  }
}
