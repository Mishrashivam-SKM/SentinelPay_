import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_decorations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Your Invisible\nUPI Guardian',
      'body': 'We analyze every transaction in real-time, operating silently in the background to ensure your money stays safe.',
      'icon': Icons.security_rounded,
      'badge': 'Zero-Knowledge Architecture',
    },
    {
      'title': 'Personalized AI\nProtection',
      'body': 'Sentinel AI learns your unique spending patterns to catch fraud that generic rules miss.',
      'icon': Icons.memory_rounded,
      'badge': 'On-Device Machine Learning',
    },
    {
      'title': 'Privacy Absolute\nBy Design',
      'body': 'Your data never leaves your phone. We don\'t track you, we don\'t sell your data, we just protect your money.',
      'icon': Icons.lock_outline_rounded,
      'badge': 'No Cloud Syncing',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/sms_permission');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/sms_permission'),
                child: Text(
                  'Skip',
                  style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon graphic
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: AppDecorations.aiGlowEmerald,
                                ),
                              ),
                              Icon(
                                _pages[index]['icon'] as IconData,
                                size: 64,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                        
                        const SizedBox(height: 48),
                        
                        Text(
                          _pages[index]['title'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineLg,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          _pages[index]['body'] as String,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                _pages[index]['badge'] as String,
                                style: AppTypography.labelCaps.copyWith(color: AppColors.onSurface),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next/Continue button
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
                            style: AppTypography.titleMd.copyWith(color: AppColors.onPrimary),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.onPrimary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
