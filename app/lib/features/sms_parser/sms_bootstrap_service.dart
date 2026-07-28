import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/data/database/transaction_dao.dart';
import 'sms_parser.dart';
import 'mock_sms_data.dart';
import 'dart:io' show Platform;

class SmsBootstrapService {
  final TransactionDao _transactionDao = TransactionDao();
  final SmsParser _parser = SmsParser();

  // Progress callback: (processedCount, matchedCount, totalCount)
  Future<void> bootstrapFromSmsHistory(Function(int, int, int) onProgress) async {
    int processed = 0;
    int matched = 0;

    // Use mock data if not Android (e.g. testing on macOS/Chrome)
    if (!Platform.isAndroid) {
      final messages = MockSmsData.getMockMessages();
      int total = messages.length;
      
      for (var msg in messages) {
        await Future.delayed(const Duration(milliseconds: 50)); // simulate work
        final parsed = _parser.tryParseSms(
          msg['sender'] as String,
          msg['body'] as String,
          msg['date'] as DateTime,
        );

        if (parsed != null) {
          await _transactionDao.insertTransaction(parsed);
          matched++;
        }
        processed++;
        onProgress(processed, matched, total);
      }
      return;
    }

    // Actual Android implementation using flutter_sms_inbox package
    var permission = await Permission.sms.status;
    if (permission.isDenied) {
      permission = await Permission.sms.request();
    }
    
    if (permission.isGranted) {
      final SmsQuery query = SmsQuery();
      final List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      
      int total = messages.length;
      
      for (var msg in messages) {
        if (msg.address != null && msg.body != null && msg.date != null) {
          final parsed = _parser.tryParseSms(
            msg.address!,
            msg.body!,
            msg.date!,
          );

          if (parsed != null) {
            await _transactionDao.insertTransaction(parsed);
            matched++;
          }
        }
        processed++;
        
        // Report progress every 10 messages to avoid UI blocking
        if (processed % 10 == 0 || processed == total) {
          onProgress(processed, matched, total);
        }
      }
    }
  }
}

