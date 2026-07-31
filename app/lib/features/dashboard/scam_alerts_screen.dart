// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/data/models/scam_message.dart';
import '../../core/data/database/scam_dao.dart';
import 'package:intl/intl.dart';
import '../../core/data/database/blocklist_dao.dart';
import '../../core/data/models/blocked_entity.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScamAlertsScreen extends StatefulWidget {
  const ScamAlertsScreen({super.key});

  @override
  State<ScamAlertsScreen> createState() => _ScamAlertsScreenState();
}

class _ScamAlertsScreenState extends State<ScamAlertsScreen> {
  final ScamDao _dao = ScamDao();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Security Alerts', style: AppTypography.titleMd),
      ),
      body: FutureBuilder<List<ScamMessage>>(
        future: _dao.getAllScamMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.8)),
                  const SizedBox(height: 16),
                  Text('Inbox Secure', style: AppTypography.headlineLg),
                  const SizedBox(height: 8),
                  Text('No scam or suspicious messages detected.', style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
            );
          }

          final alerts = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 100.0),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return AlertCard(alert: alert);
            },
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class AlertCard extends StatefulWidget {
  final ScamMessage alert;

  const AlertCard({super.key, required this.alert});

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  final BlocklistDao _blocklistDao = BlocklistDao();
  bool _isBlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBlockStatus();
  }

  Future<void> _checkBlockStatus() async {
    final isBlocked = await _blocklistDao.isBlocked(widget.alert.sender, EntityType.sms);
    if (mounted) {
      setState(() {
        _isBlocked = isBlocked;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBlock() async {
    setState(() => _isLoading = true);
    if (_isBlocked) {
      await _blocklistDao.unblockEntity(widget.alert.sender, EntityType.sms);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sender unblocked.')),
        );
      }
    } else {
      await _blocklistDao.blockEntity(BlockedEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityValue: widget.alert.sender,
        entityType: EntityType.sms,
        timestamp: DateTime.now(),
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sender blocked in Sentinel filter.')),
        );
      }
    }
    await _checkBlockStatus();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhishing = widget.alert.scamType == 'phishing';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isPhishing ? Icons.phishing_rounded : Icons.warning_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                isPhishing ? 'Phishing Attempt' : 'Suspicious OTP',
                style: AppTypography.titleMd.copyWith(color: AppColors.error),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM dd, hh:mm a').format(widget.alert.timestamp),
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'From: ${widget.alert.sender}',
            style: AppTypography.labelCaps.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.alert.scamType == 'phishing' 
                ? 'This message contains a suspicious link intended to steal your information.'
                : 'This message asks for sensitive information or OTP which should never be shared.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _toggleBlock,
                  icon: Icon(_isBlocked ? Icons.check_circle_rounded : Icons.block_rounded, size: 18),
                  label: Text(_isBlocked ? 'Unblock Sender' : 'Block Sender'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isBlocked ? AppColors.primary : AppColors.error,
                    side: BorderSide(color: _isBlocked ? AppColors.primary : AppColors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
