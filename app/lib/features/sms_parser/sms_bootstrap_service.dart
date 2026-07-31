import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/data/database/transaction_dao.dart';
import '../../core/data/database/scam_dao.dart';
import '../ml/scam_detector_ml.dart';
import 'sms_parser.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../../core/data/models/parsed_transaction.dart';

class SmsBootstrapService {
  final TransactionDao _transactionDao = TransactionDao();
  final ScamDao _scamDao = ScamDao();
  final SmsParser _parser = SmsParser();
  final ScamDetectorML _scamDetector = ScamDetectorML();

  // Progress callback: (processedCount, matchedCount, totalCount)
  Future<void> bootstrapFromSmsHistory(Function(int, int, int) onProgress) async {
    int processed = 0;
    int matched = 0;

    // SMS inbox is only available on Android.
    if (!Platform.isAndroid) {
      debugPrint('SMS parsing is only supported on Android. Skipping bootstrap.');
      return;
    }

    // Actual Android implementation using flutter_sms_inbox package
    var permission = await Permission.sms.status;
    
    if (permission.isGranted) {
      final SmsQuery query = SmsQuery();
      final prefs = await SharedPreferences.getInstance();
      final lastSyncTime = prefs.getInt('last_synced_sms_timestamp') ?? 0;
      
      final List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      
      final newMessages = messages.where((m) => 
        m.date != null && m.date!.millisecondsSinceEpoch > lastSyncTime
      ).toList();
      
      int total = newMessages.length;
      
      if (total == 0) {
        onProgress(1, 0, 1);
        return;
      }
      
      for (var msg in newMessages) {
        if (msg.address != null && msg.body != null && msg.date != null) {
          final parsed = _parser.tryParseSms(
            msg.address!,
            msg.body!,
            msg.date!,
          );

          if (parsed != null) {
            // P0-04 Fix: Deterministic ID for deduplication with 1-minute fuzzy window
            final fuzzyMinute = (msg.date!.millisecondsSinceEpoch / 60000).floor().toString();
            final bytes = utf8.encode(msg.address! + msg.body! + fuzzyMinute);
            final digest = sha256.convert(bytes);
            
            String? finalVerdict = parsed.verdict;
            if (finalVerdict == null) {
              final pending = prefs.getString('pending_verdict');
              if (pending != null && msg.date!.isAfter(DateTime.now().subtract(const Duration(minutes: 5)))) {
                 finalVerdict = pending;
                 await prefs.remove('pending_verdict');
              } else {
                 finalVerdict = 'safe'; // default assumption
              }
            }

            final dedupTx = ParsedTransaction(
              id: digest.toString(),
              amount: parsed.amount,
              direction: parsed.direction,
              method: parsed.method,
              payeeIdentifier: parsed.payeeIdentifier,
              payeeName: parsed.payeeName,
              timestamp: parsed.timestamp,
              sourceBank: parsed.sourceBank,
              matchedTemplateId: parsed.matchedTemplateId,
              source: parsed.source,
              verdict: finalVerdict,
            );
            await _transactionDao.insertTransaction(dedupTx);
            matched++;
          } else {
            // Check for scams
            final scamMsg = _scamDetector.evaluateMessage(msg.address!, msg.body!, msg.date!);
            if (scamMsg != null) {
              await _scamDao.insertScamMessage(scamMsg);
            }
          }
        }
        processed++;
        
        // Report progress every 10 messages to avoid UI blocking
        if (processed % 10 == 0 || processed == total) {
          onProgress(processed, matched, total);
        }
      }
      
      await prefs.setInt('last_synced_sms_timestamp', DateTime.now().millisecondsSinceEpoch);
    } else {
      // Permission not granted, graceful degradation: do nothing, onProgress is still called to complete.
      onProgress(1, 0, 1); 
    }
  }
}


