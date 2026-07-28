import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.titleMd),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSettingsGroup(
            'Privacy & Data',
            [
              _buildSettingsRow(Icons.sms_outlined, 'SMS Permission', trailing: Switch(value: true, activeColor: AppColors.primary, onChanged: (v) {})),
              _buildSettingsRow(Icons.data_usage_outlined, 'View Parsed History', onTap: () {}),
              _buildSettingsRow(Icons.delete_outline, 'Delete All Data', isDestructive: true, onTap: () {}),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsGroup(
            'Notifications',
            [
              _buildSettingsRow(Icons.notifications_active_outlined, 'Push Notifications', trailing: Switch(value: true, activeColor: AppColors.primary, onChanged: (v) {})),
              _buildSettingsRow(Icons.warning_amber_rounded, 'High Risk Alerts Only', trailing: Switch(value: false, activeColor: AppColors.primary, onChanged: (v) {})),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsGroup(
            'Developer Options',
            [
              _buildSettingsRow(Icons.science_outlined, 'Demo Mode (Mock SMS)', trailing: Switch(value: true, activeColor: AppColors.primary, onChanged: (v) {})),
              _buildSettingsRow(Icons.bug_report_outlined, 'Force Retrain Model', onTap: () {}),
            ],
          ),
          
          const SizedBox(height: 100),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
  
  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(title, style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingsRow(IconData icon, String title, {Widget? trailing, bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTypography.bodyLg.copyWith(color: color))),
            if (trailing != null) trailing
            else if (onTap != null) Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
