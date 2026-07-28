import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class CommunityReportService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch a list of universally flagged malicious UPI VPAs.
  Future<List<String>> getFlaggedVpas() async {
    try {
      final response = await _client.from('flagged_vpas').select('vpa');
      final List<String> flaggedList = (response as List<dynamic>)
          .map((row) => row['vpa'] as String)
          .toList();
      return flaggedList;
    } catch (e) {
      debugPrint('Failed to fetch flagged VPAs: $e');
      return [];
    }
  }

  /// Report a malicious VPA to the global community database.
  Future<void> reportVpa(String vpa, String reason) async {
    try {
      await _client.from('flagged_vpas').insert({
        'vpa': vpa,
        'reason': reason,
        'reported_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Successfully reported VPA to community.');
    } catch (e) {
      debugPrint('Failed to report VPA: $e');
    }
  }
}
