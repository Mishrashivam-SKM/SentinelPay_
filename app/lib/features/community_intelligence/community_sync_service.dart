// coverage:ignore-file
import 'package:flutter/foundation.dart';

class CommunitySyncService {


  /// Pushes local scam reports to the community database
  Future<void> syncLocalScamsToCommunity() async {
    // P0-08 / P0-09 Fix: Community Sync disabled for V1 due to privacy and abuse concerns.
    debugPrint('Community Sync is disabled for V1. Deferred to V2.');
    return;
  }
}
