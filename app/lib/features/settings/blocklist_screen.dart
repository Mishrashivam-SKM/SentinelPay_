// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/data/database/blocklist_dao.dart';
import '../../core/data/models/blocked_entity.dart';
import 'package:intl/intl.dart';

class BlocklistScreen extends StatefulWidget {
  const BlocklistScreen({super.key});

  @override
  State<BlocklistScreen> createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends State<BlocklistScreen> {
  final BlocklistDao _dao = BlocklistDao();
  late Future<List<BlockedEntity>> _blocklistFuture;

  @override
  void initState() {
    super.initState();
    _refreshBlocklist();
  }

  void _refreshBlocklist() {
    setState(() {
      _blocklistFuture = _dao.getAllBlockedEntities();
    });
  }

  Future<void> _unblock(BlockedEntity entity) async {
    await _dao.unblockEntity(entity.entityValue, entity.entityType);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unblocked ${entity.entityValue}')),
      );
      _refreshBlocklist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Blocklist', style: AppTypography.titleMd),
      ),
      body: FutureBuilder<List<BlockedEntity>>(
        future: _blocklistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('No Blocked Entities', style: AppTypography.headlineLg),
                  const SizedBox(height: 8),
                  Text('Senders or payees you block will appear here.', style: AppTypography.bodyLg.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          final list = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entity = list[index];
              final bool isSms = entity.entityType == EntityType.sms;
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      child: Icon(
                        isSms ? Icons.message_rounded : Icons.qr_code_rounded,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entity.entityValue, style: AppTypography.titleMd),
                          Text(
                            isSms ? 'Blocked Sender' : 'Blocked Payee (UPI)',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Blocked on: ${DateFormat('MMM dd, yyyy').format(entity.timestamp)}',
                            style: AppTypography.labelCaps.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline_rounded, color: AppColors.onSurfaceVariant),
                      tooltip: 'Unblock',
                      onPressed: () => _unblock(entity),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
