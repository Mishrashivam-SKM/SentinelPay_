class UpiParser {
  final String uri;

  UpiParser(this.uri);

  bool get isValidUpiUri {
    return uri.toLowerCase().startsWith('upi://pay');
  }

  String? get payeeVpa {
    if (!isValidUpiUri) return null;
    final uriObj = Uri.tryParse(uri);
    return uriObj?.queryParameters['pa'];
  }

  String? get payeeName {
    if (!isValidUpiUri) return null;
    final uriObj = Uri.tryParse(uri);
    return uriObj?.queryParameters['pn'];
  }

  double? get amount {
    if (!isValidUpiUri) return null;
    final uriObj = Uri.tryParse(uri);
    final am = uriObj?.queryParameters['am'];
    if (am != null) {
      return double.tryParse(am);
    }
    return null;
  }
}
