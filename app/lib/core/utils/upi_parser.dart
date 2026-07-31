class UpiParser {
  final String uri;

  UpiParser(this.uri);

  bool get isValidUpiUri {
    if (!uri.toLowerCase().startsWith('upi://pay')) return false;
    
    final uriObj = Uri.tryParse(uri);
    if (uriObj == null) return false;
    
    // Check VPA format
    final vpa = uriObj.queryParameters['pa'];
    if (vpa == null || vpa.isEmpty) return false;
    if (!RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z0-9]+$').hasMatch(vpa)) return false;
    
    // Check amount
    final amStr = uriObj.queryParameters['am'];
    if (amStr != null) {
      final parsed = double.tryParse(amStr);
      if (parsed == null || parsed <= 0 || parsed > 200000) return false; 
    }
    
    // Check currency
    final cu = uriObj.queryParameters['cu'];
    if (cu != null && cu.toUpperCase() != 'INR') return false;
    
    return true;
  }

  String? get payeeVpa {
    final uriObj = Uri.tryParse(uri);
    return uriObj?.queryParameters['pa'];
  }

  String? get payeeName {
    final uriObj = Uri.tryParse(uri);
    final pn = uriObj?.queryParameters['pn'];
    if (pn == null) return null;
    // Sanitize: allow only alphanumeric and spaces
    return pn.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
  }

  double? get amount {
    final uriObj = Uri.tryParse(uri);
    final am = uriObj?.queryParameters['am'];
    if (am != null) {
      final parsed = double.tryParse(am);
      if (parsed != null && parsed > 0 && parsed <= 200000) {
        return parsed;
      }
    }
    return null;
  }
}
