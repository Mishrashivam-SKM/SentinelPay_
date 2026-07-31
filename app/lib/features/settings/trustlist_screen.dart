// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/data/database/trustlist_dao.dart';
import '../../core/data/models/blocked_entity.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TrustlistScreen extends StatefulWidget {
  const TrustlistScreen({super.key});

  @override
  State<TrustlistScreen> createState() => _TrustlistScreenState();
}

class _TrustlistScreenState extends State<TrustlistScreen> {
  final TrustlistDao _dao = TrustlistDao();
  List<BlockedEntity> _trustedEntities = []; // Using BlockedEntity model for simplicity as the schema is identical
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrustlist();
  }

  Future<void> _loadTrustlist() async {
    setState(() => _isLoading = true);
    final entities = await _dao.getAllTrustedEntities();
    setState(() {
      _trustedEntities = entities;
      _isLoading = false;
    });
  }

  Future<void> _untrustEntity(BlockedEntity entity) async {
    await _dao.untrustEntity(entity.entityValue, entity.entityType);
    await _loadTrustlist();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${entity.entityValue} removed from Trustlist')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trusted Payees', style: AppTypography.titleMd),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trustedEntities.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trustedEntities.length,
                  itemBuilder: (context, index) {
                    final entity = _trustedEntities[index];
                    return _buildTrustedCard(entity, index);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No Trusted Payees',
            style: AppTypography.titleMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Payees you explicitly trust will appear here.',
            style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildTrustedCard(BlockedEntity entity, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.green.withValues(alpha: 0.2),
          child: const Icon(Icons.verified_user, color: Colors.green),
        ),
        title: Text(entity.entityValue, style: AppTypography.titleMd),
        subtitle: Text(
          'Added: ${DateFormat.yMMMd().format(entity.timestamp)}',
          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: OutlinedButton(
          onPressed: () => _untrustEntity(entity),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
          ),
          child: const Text('Untrust'),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
  }
}
