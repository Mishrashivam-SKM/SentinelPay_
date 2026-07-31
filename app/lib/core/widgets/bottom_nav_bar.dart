// coverage:ignore-file
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            border: const Border(
              top: BorderSide(
                color: Color(0x1AFFFFFF),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, 'Home', '/dashboard'),
              _buildNavItem(context, 1, Icons.warning_rounded, 'Alerts', '/scam_alerts'),
              _buildNavItem(context, 2, Icons.history_rounded, 'History', '/history'),
              _buildNavItem(context, 3, Icons.settings_rounded, 'Settings', '/settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          context.go(route);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelCaps.copyWith(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
