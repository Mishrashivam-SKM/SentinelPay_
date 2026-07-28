import '../../../core/data/models/parsed_transaction.dart';

class DeterministicIntelligence {
  // Hardcoded blocklist for demo purposes
  static const List<String> _blockedVpas = [
    'scammer@ybl',
    'fraud@icici',
    'win_lottery@okaxis'
  ];

  double scoreDeterministic(ParsedTransaction current) {
    if (current.payeeIdentifier != null && 
        _blockedVpas.contains(current.payeeIdentifier!.toLowerCase())) {
      return 1.0; // 1.0 = absolute highest risk
    }
    
    // Pattern matching for suspicious names
    if (current.payeeName != null) {
      final lowerName = current.payeeName!.toLowerCase();
      if (lowerName.contains('cashback') || lowerName.contains('lottery') || lowerName.contains('support')) {
        return 0.9;
      }
    }
    
    return 0.0; // 0.0 = no deterministic risk found
  }
}
