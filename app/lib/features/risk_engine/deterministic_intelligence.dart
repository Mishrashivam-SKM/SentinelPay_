import '../../../core/data/models/parsed_transaction.dart';
import '../../../core/data/database/blocklist_dao.dart';
import '../../../core/data/models/blocked_entity.dart';

class DeterministicIntelligence {
  final BlocklistDao _blocklistDao = BlocklistDao();
  // Hardcoded blocklist for demo purposes
  static const List<String> _blockedVpas = [
    'scammer@ybl',
    'fraud@icici',
    'win_lottery@okaxis'
  ];

  Future<double> scoreDeterministic(ParsedTransaction current) async {
    if (current.payeeIdentifier != null) {
      final vpa = current.payeeIdentifier!.toLowerCase();
      
      // Check hardcoded lists first
      if (_blockedVpas.contains(vpa)) return 1.0;
      
      // Check user's blocklist
      final isBlocked = await _blocklistDao.isBlocked(current.payeeIdentifier!, EntityType.upi);
      if (isBlocked) return 1.0;
    }
    
    // Pattern matching for suspicious names is removed to prevent false positives
    // like "Dell Support" or legitimate business cashback schemes.
    
    return 0.0; // 0.0 = no deterministic risk found
  }
}
