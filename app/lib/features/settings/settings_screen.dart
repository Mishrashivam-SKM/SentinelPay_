// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/data/database/transaction_dao.dart';
import '../../core/data/database/database_helper.dart';

import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  
  bool _biometricsEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final bio = await _storage.read(key: 'biometrics_enabled') == 'true';
    if (mounted) {
      setState(() {
        _biometricsEnabled = bio;
      });
    }
  }

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
            'Security',
            [
              _buildSettingsRow(
                Icons.fingerprint_rounded, 
                'Enable Biometrics', 
                trailing: Switch(
                  value: _biometricsEnabled, 
                  activeThumbColor: AppColors.primary, 
                  onChanged: (v) async {
                    await _storage.write(key: 'biometrics_enabled', value: v.toString());
                    setState(() => _biometricsEnabled = v);
                  }
                ),
              ),
              _buildSettingsRow(
                Icons.block_rounded,
                'Manage Blocklist',
                onTap: () => context.push('/blocklist'),
              ),
              _buildSettingsRow(
                Icons.verified_user_outlined,
                'Manage Trusted Payees',
                onTap: () => context.push('/trustlist'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsGroup(
            'Privacy & Data',
            [
              _buildSettingsRow(
                Icons.sms_outlined, 
                'SMS Permission Settings', 
                onTap: () {
                  openAppSettings();
                }
              ),
              _buildSettingsRow(Icons.delete_outline, 'Delete All Data', isDestructive: true, onTap: () async {
                await const FlutterSecureStorage().deleteAll();
                await DatabaseHelper().deleteDatabaseFile();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data deleted.')));
                  context.go('/welcome');
                }
              }),
            ],
          ),
          
          // Developer options removed for V1
          
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
